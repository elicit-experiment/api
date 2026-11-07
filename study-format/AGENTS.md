# Working on the study-format package

These instructions supplement [the repository instructions](../AGENTS.md).

## Sources of truth

- `elicit_study/contracts/components.json`: versioned component configuration and output payload contracts.
- `elicit_study/schema.py`: document structure and assembly of the editor schema.
- `elicit_study/contracts/study.schema.json`: generated, checked-in, self-contained JSON Schema draft-07 artifact. Do not hand-edit it.
- `elicit_study/compiler.py`: normalization, semantic checks, identities and configuration-dependent result bindings.
- `elicit_study/parquet.py`: physical Arrow/Parquet mapping and manifest-last artifact writing.
- `elicit_study/delivery.py`: file-based worker bridge, whole-batch reference validation and ZIP packaging.
- `elicit_study/client.py`: authenticated async API client and verified downloads.

Read [schema.md](docs/schema.md) for document/result semantics and [python.md](docs/python.md) for the supported library surface. Keep those references and the package README consistent with behavior.

## Editing contracts

Preserve offline use: authoring/compilation must not fetch assets, schemas, credentials, participants or server data. Keep schema resources inside the installed wheel and avoid remote `$ref` dependencies. JSON Schema validation and semantic compiler checks are both required.

After editing the registry or document assembler, regenerate the schema from the repository root:

```sh
elicit-study schema --output study-format/elicit_study/contracts/study.schema.json
python -m unittest discover -s study-format/tests -v
```

Install with `python -m pip install -e './study-format[parquet]'` first. Use the virtual environment described in the root instructions when system Python is managed. Tests must run with PyArrow available when verifying exports; a skipped Parquet test is not export validation.

When adding a component, specify config and output schemas, defaults, semantic checks and configuration-dependent output constraints. Cover valid and invalid cases and a representative study. Update `examples/catalog.json`, documentation and the explicit example-count/registry-coverage assertions if example coverage intentionally changes. Keep identifiers independent of database IDs and labels. Store output as typed fields, not JSON strings hidden inside a generic value column.

The current format is experimental. Before release, freeze its contracts; after release, incompatible changes require explicit versioning. Consider `schema_version`, component `type_version`, compiler version, export `format_version` and result contract identity separately. Never mutate a published revision or silently recompile its stored contract during ingestion/export.

## Results and delivery

`validate_row` checks one row only. Use batch validation for identities and run/occurrence relationships. The local writer does not establish a database snapshot or cross-row integrity; those are upstream responsibilities. Preserve separate trial occurrences, sequence scopes, timezone-aware microsecond timestamps, schemaful empty tables and nullable values.

Use bounded batches and finalized immutable parts; publish the manifest only after every part exists. Do not assume partial files form a usable export. The client must preserve existing destination files, reject corrupt downloads and keep bearer tokens off storage requests and cross-origin redirects. Do not implement silent network retries that create new operations or hide server diagnostics.

For server bridge changes also run the Rails integration and real worker checks listed in the root instructions. For docs, execute new self-contained snippets locally and check links. Keep the distinction between local APIs, the worker protocol, async server operations and the still-unimplemented participant runtime adapter explicit.
