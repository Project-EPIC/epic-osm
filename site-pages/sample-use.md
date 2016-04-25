---
layout: page
title: Example Use
permalink: /example
---

Here is an example of working with the framework interactively in your own Ruby program. This was done in a Ruby notebook in Jupyter.  [The full notebook is available here](https://gist.github.com/jenningsanderson/83333abfdc7964ad7e31453c0412a17a).

### Analysis Window
The main object of epic-osm is an analysis window. This is a spatio-temporal bounding box that may define the questions one wishes to ask of the data as well as tell the framework where to find the data and where to save the output.

It is currently implemented as an exectuable spec written in YAML.

    title:      'Nepal Earthquake'
    
    start_date: '2015-04-25'
    end_date:   '2015-05-31'     
    bbox:       '80.0134,26.3033,88.2202,30.5149'

    #Database & IO Configuration
    database:   'nepal-earthquake3'
    write_directory: '/data/www/nepal-earthquake-aag-2016'

### Working with the Framework
First, load the library and initialize an analysis window.

    require '/opt/epic-osm/epic-osm.rb'
    analysis_window = './nepal-earthquake.yml'
    o  = EpicOSM.new(analysis_window: analysis_window)
    aw = o.analysis_window
    
Now call functions against the analysis window

    cSets_per_4hours = aw.changesets_x_hour(step: 4);

The structure of every query result is a series of temporal buckets of the form: 
    
    {start: <Time> end: <Time> objects: <array of domain objects>}

Inspecting the bucket:

    puts "Start: #{cSets_per_4hours[1][:start_date]} | End: #{cSets_per_4hours[1][:end_date]}  | Objects: #{cSets_per_4hours[1][:objects].length}"
    
```Start: 2015-04-25 04:00:00 +0000 | End: 2015-04-25 08:00:00 +0000  | Objects: 11```

Next, iterate over the buckets and save lists of unique editors per bucket to another data structure.

    users_per_4hours = cSets_per_4hours.collect{|bucket| 
      {time: bucket[:start_date],
       all_users: bucket[:objects].collect{|x| x.user}.uniq,
       hot_users: bucket[:objects].select{|c| c.comment =~ /hot/}.collect{|x| x.user}.uniq
      }
    }

Save the geometries for each of these edits as well. Additionally, filter off the potential not_hot users as well.

    geometries_per_4_hours = cSets_per_4hours.collect{|bucket| 
      {time: bucket[:start_date],
        all_geometries: bucket[:objects].collect{|x| {geom: x.geometry, area: x.area, user: x.user}},
        hot_geometries: bucket[:objects].select{|c| c.comment =~ /hot/}.collect{|x| {geom: x.geometry, area: x.area, user: x.user}},
        not_hot_geometries: bucket[:objects].select{|c| not c.comment =~ /hot/}.collect{|x| {geom: x.geometry, area: x.area, user: x.user}}
       }
    }

Just count the number of editors in each bucket (NOT Unique overall)

    counts_per_4_hours = users_per_4hours.collect{ |d| 
          { time:      d[:time],
            all_users: d[:all_users].count,
            hot_users: d[:hot_users].count
          }
        };
        
Write results to disk as JSON for further visualization and analysis in Python/Javascript

    results = File.write('json/geometries_per_4_hours.json', geometries_per_4_hours.to_json)
    puts "Successfully wrote #{results.to_i / 1024} kb to Disk"

```Successfully wrote 76096 kb to Disk```

    results = File.write('json/users_per_4_hours.json', users_per_4hours.to_json)
    puts "Successfully wrote #{results.to_i / 1024} kb to Disk"
    
```Successfully wrote 467 kb to Disk```

### Visualizing the Data
With Jupyter and iPython, it is easy to read the JSON results into a new notebook to visualize:

<script src="https://gist.github.com/jenningsanderson/1727ead2523c01861843af08af8cbd5b.js"></script>

