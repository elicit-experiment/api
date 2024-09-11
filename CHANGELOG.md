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

### Sep 9, 2024

* Add IncludeLandmarks configuration. This is configured via:

```
IncludeLandmarks = '1,2,5,100,346'
```

and the results look like:

```json
{"timeStamp":1725848056969,"faceLandmarks":[[{"x":0.7338126301765442,"y":0.9374626278877258,"index":1},{"x":0.7265433073043823,"y":0.9391292333602905,"index":2},{"x":0.7364553213119507,"y":0.9068315029144287,"index":5}

```
where the `index` is the original landmark index.

* Create new `NewComponent::FaceLandmarkerCalibration` component:

```python
trial_definition_specification = dict(trial_definition=dict(name='Landmarker calibration',
                                                            definition_data=dict(
                                                                    TrialType='Calibration',
                                                                    type='NewComponent::FaceLandmarkCalibration',
                                                                    # number of faces expected in the interface
                                                                    NumberOfFaces=2,
                                                                    Landmarks=True,  # return Landmark data
                                                                    Blendshapes=True,  # return Blendshape data
                                                                    FaceTransformation=True,
                                                                    # indicate if the affine transform should be performed or not
                                                                    CalibrationDuration=5,
                                                                    # duration of face within view measured in seconds
                                                                    StripZCoordinates=True,
                                                                    # IncludeBlendshapes='eyeLookInRight,eyeLookInLeft',
                                                                    IncludeLandmarks = '1,2,5,100,346'
                                                                    )))
```

This component is very barebones at the moment. It includes a flow to ask the subject to stabilize their head in front of the webcam for 5s, then click on all the points as in the previous webgazer calibration.

The timestamps and x,y screen coordinates of the clicks are included in the `DataPoint` for the calibration trial and look like this in JSON:

```json
{"calibrationPoints":{"Pt1":[{"x":346,"y":77,"timeStamp":1725846604989}],"Pt2":[{"x":1196,"y":80,"timeStamp":1725846607471}],"Pt3":[{"x":2328,"y":82,"timeStamp":1725846610401}],"Pt6":[{"x":2326,"y":768,"timeStamp":1725846612052}],"Pt9":[{"x":2318,"y":1458,"timeStamp":1725846613323}],"Pt8":[{"x":1195,"y":1455,"timeStamp":1725846614703}],"Pt7":[{"x":51,"y":1453,"timeStamp":1725846616246}],"Pt4":[{"x":62,"y":772,"timeStamp":1725846617441}],"Pt5":[{"x":1200,"y":769,"timeStamp":1725846618850}]}}
```

Each point has a series of x,y click coordinates and timestamps associated with it. This can then be correlated with the face landmark data at the same time.
