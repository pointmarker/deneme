#!/bin/bash
while IFS="|" read id dev_id project_id applied_at bid
do  
echo $project_id -- $bid
done < data/applications.txt