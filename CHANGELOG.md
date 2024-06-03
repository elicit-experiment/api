### Jun 3, 2024

Initial FaceLandmarker Release

* Add Facelandmarker prototype
  * Add `NewComponent::FaceLandmarker` component.
  * Add `tests/Testcase_landmarker.py` client-api example of how to create the component.
  * Add new type of timeseries upload to support the landmarker: newline-delimited JSON (NDJSON)
* Fix MouseTracking timeseries (i.e. how it works with webgazer)

In order to incorporate the FaceLandmarker component some infrastructure changes were needed:

* Move from CommonJS imports to ESM to support modern modules
* Upgrade KnockoutJS

