
## OneDScaleT

Complete

## Push YouTube API events

Now they events from a YouTube video look like:

```javascript
{
  "Tags":[{"Id":"2","Label":"indifferent"},{"Id":"2","Label":"middle"}],
  "Events":[
    {"Id":"Video","Type":"UNSTARTED","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"Video","DateTime":"2021-05-23T17:41:06.094Z"},
    {"Id":"Video","Type":"BUFFERING","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"Video","DateTime":"2021-05-23T17:41:06.095Z"},
    {"Id":"Video","Type":"PLAYING","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"Video","DateTime":"2021-05-23T17:41:06.592Z"},
    {"Id":"Video","Type":"Start","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"video/youtube","DateTime":"2021-05-23T17:41:06.592Z"},
    {"Id":"Video","Type":"ENDED","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"Video","DateTime":"2021-05-23T17:41:16.894Z"},
    {"Id":"Video","Type":"Stop","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"video/youtube","DateTime":"2021-05-23T17:41:16.894Z"},
    {"Id":"Video","Type":"Completed","EntityType":"Stimulus","Method":"/Instrument/Stimulus","Data":"video/youtube","DateTime":"2021-05-23T17:41:16.895Z"},
    {"Id":"TaggingB","Type":"Change","EntityType":"Instrument","Method":"Mouse/Left/Down","Data":"indifferent","DateTime":"2021-05-23T17:42:33.700Z"},
    {"Id":"TaggingB","Type":"Change","EntityType":"Instrument","Method":"Mouse/Left/Down","Data":"middle","DateTime":"2021-05-23T17:42:35.932Z"}
    ]
}
```

With the UPPERCASE events being those that come from the Youtube API.
