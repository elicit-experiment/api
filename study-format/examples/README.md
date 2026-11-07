# Reworked client-api examples

These nine studies were selected for feature coverage, not measured popularity. The source repository and exact revision are recorded in [catalog.json](catalog.json). Files are complete offline authoring documents, with no API call chains or participant-management side effects.

| New study | Original client-api example(s) | Coverage |
| --- | --- | --- |
| [01-likert](01-likert.study.json) | `Testcase_likertscale.py` | Nine choices, required rating, attached audio, layout |
| [02-single-choice](02-single-choice.study.json) | `Testcase_radiobutton.py` | Optional/required choices, correctness metadata, feedback |
| [03-multiple-choice](03-multiple-choice.study.json) | `Testcase_checkboxgroup.py` | Array answers and selection cardinality |
| [04-free-text](04-free-text.study.json) | `Testcase_freetext.py` | Multiline, optional, pattern and length constraints |
| [05-scale](05-scale.study.json) | `Testcase_onedscale.py` | Numeric bounds and ticks |
| [06-instrument-stimuli](06-instrument-stimuli.study.json) | `Testcase_instrument_stimuli.py`, `Testcase_image_stimuli.py` | Image/audio/video assets, attached and standalone media |
| [07-video-monitoring](07-video-monitoring.study.json) | `Testcase_video_stimuli_timing.py`, `Testcase_video_stimuli.py` | Playback events, mouse samples, keyboard events |
| [08-face-landmarks](08-face-landmarks.study.json) | `Testcase_landmarker_calibration.py`, `Testcase_landmarker.py` | Calibration, landmarks, blendshapes, 2D/3D capture |
| [09-ordering-completion](09-ordering-completion.study.json) | `Testcase_TrialOrder_anonymous.py`, `random-and-completion-code.py`, `Testcase_completioncode.py` | Shuffle, replacement sampling, completion codes |

These are curated rewrites of the workflows, not lossless imports of every historical presentation variant. Repeated label-position, column-width and axis-decoration permutations are consolidated. Legacy enrolment, fixed user IDs, passwords, redirects and server-specific metadata are intentionally outside this portable definition. Source trials that put calibration settings directly in trial metadata are expressed as explicit calibration components. Random per-user sequence creation becomes a declarative per-run ordering rule. Completion is placed after randomized phases.

Important remaining parity work: exact legacy layout/markup rendering, keyboard method names, face transformation matrices, WebGazer, TaggingA and other unselected component types, legacy result normalization, mapping legacy attached-media events to asset keys, and end-to-end browser behavior. The new documents are not currently accepted by the v1 runtime. Their configured behavior and output shapes are proposals enforced by this package, awaiting the runtime adapter.

Open any `.study.json` file in a JSON Schema-aware editor for local completion. From the repository root, validate with:

```bash
elicit-study validate study-format/examples/08-face-landmarks.study.json
```
