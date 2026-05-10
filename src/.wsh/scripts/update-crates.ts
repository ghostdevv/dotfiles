import { confirm, intro, isCancel, log, outro, spinner } from 'npm:@clack/prompts@1.3.0';
import * as semver from 'jsr:@std/semver@1.0.8';
import * as c from 'jsr:@std/fmt@1.0.10/colors';
import * as v from 'jsr:@valibot/valibot@1.4.0';
import { resolve } from 'jsr:@std/path@1.1.4';
import * as toml from 'jsr:@std/toml@1.0.11';
import { dset } from 'npm:dset@3.1.4';
import { inspect } from 'node:util';
import { t } from 'npm:try@1.0.3';

function exit(error: boolean, message: string): never {
	if (error) {
		log.error(message);
	} else {
		log.info(message);
	}

	Deno.exit(Number(error));
}

intro('update-crates script');

const cargoTomlPath = resolve('./Cargo.toml');
if (!cargoTomlPath) exit(true, 'Unable to find ./Cargo.toml');

const content = await t(Deno.readTextFile(cargoTomlPath));
if (!content.ok) exit(true, 'Unable to find ./Cargo.toml');

const Dependencies = v.record(
	v.string(),
	v.union([v.string(), v.object({ version: v.string() })]),
);

const CargoTomlSchema = v.object({
	dependencies: v.optional(Dependencies),
	'build-dependencies': v.optional(Dependencies),
	target: v.optional(
		v.record(
			v.string(),
			v.object({ dependencies: v.optional(Dependencies) }),
		),
	),
});

const raw = t(() => toml.parse(content.value));
if (!raw.ok) exit(true, `Failed to parse Cargo.toml: ${c.dim(String(raw.error))}`);

const parsed = v.safeParse(CargoTomlSchema, raw.value);
if (!parsed.success) {
	const error = inspect(parsed.issues, { colors: true, depth: Infinity });
	exit(true, `Failed to parse Cargo.toml\n${error}`);
}

const versionCache = new Map<string, semver.SemVer>();

const CratesVersionsSchema = v.object({
	versions: v.pipe(
		v.array(v.object({
			crate: v.string(),
			num: v.pipe(
				v.string(),
				v.transform((s) => semver.tryParse(s)!),
				v.check((s) => typeof s !== 'undefined'),
			),
		})),
		v.minLength(1),
	),
});

async function fetchLatestVersion(crate: string): Promise<semver.SemVer> {
	const cacheHit = versionCache.get(crate);
	if (cacheHit) return cacheHit;

	const url = new URL(`https://crates.io/api/v1/crates/${encodeURIComponent(crate)}/versions`);
	url.searchParams.set('sort', 'semver');
	url.searchParams.set('per_page', '1');

	const response = await fetch(url, {
		headers: { Accept: 'application/json' },
	});

	const data = v.safeParse(CratesVersionsSchema, await response.json());

	if (!data.success) {
		const error = inspect(data.issues, { colors: true, depth: Infinity });
		exit(true, `Failed to parse crates version api response\n${error}`);
	}

	const version = data.output.versions[0].num;
	versionCache.set(crate, version);
	return version;
}

interface Results {
	crate: string;
	from: string;
	to: string | null;
}

const results: Results[] = [];
const s = spinner();

const visit = async (path: string[], dependencies: v.InferOutput<typeof Dependencies>) => {
	for (const [crate, version] of Object.entries(dependencies)) {
		s.message(`Checking ${c.bold(path.join('.'))} -> ${c.bold(crate)}`);

		const currentStr = typeof version === 'string' ? version : version.version;
		const current = semver.parse(currentStr);

		const latest = await t(fetchLatestVersion(crate));
		if (!latest.ok) {
			s.error(`Failed to get version: ${c.dim(String(latest.error))}`);
			Deno.exit(1);
		}

		if (semver.greaterThan(latest.value, current)) {
			const versionPath = [...path, crate];
			if (typeof version != 'string') versionPath.push('version');

			const latestStr = semver.format(latest.value);
			dset(raw.value, versionPath, latestStr);
			results.push({ crate, from: currentStr, to: latestStr });
		} else {
			results.push({ crate, from: currentStr, to: null });
		}
	}
};

s.start('Finding dependencies');

if (parsed.output.dependencies) {
	await visit(['dependencies'], parsed.output.dependencies);
}

if (parsed.output['build-dependencies']) {
	await visit(['build-dependencies'], parsed.output['build-dependencies']);
}

if (parsed.output.target) {
	for (const [path, data] of Object.entries(parsed.output.target)) {
		if (data.dependencies) {
			await visit(['target', path, 'dependencies'], data.dependencies);
		}
	}
}

let longestName = 0;
let updates = 0;

for (const result of results) {
	if (result.to !== null) updates++;
	if (longestName < result.crate.length) longestName = result.crate.length;
}

const resultsStr = results
	.map((change) => {
		const spacing = longestName - change.crate.length + 1;
		let result = `${c.bold(change.crate)}${' '.repeat(spacing)}${c.dim(change.from)}`;
		if (change.to) result += `\t-> ${c.green(change.to)}`;
		return result;
	})
	.join('\n');

s.stop(`Finished! ${updates === 0 ? 'No' : updates} updates found`);
log.message(resultsStr);

if (updates) {
	const save = await confirm({ message: 'Would you like to save these updates?' });
	if (isCancel(save)) exit(true, 'Cancelled');

	if (save) {
		await Deno.writeTextFile(cargoTomlPath, content.value);
		outro('Done! Run `cargo update`');
	}
}
