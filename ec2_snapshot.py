
#!/usr/bin/env python
# the script will create snapshots of volumes and delete volumes which are older than 2 weeks

import boto
from boto import ec2
from datetime import datetime
from datetime import timedelta

conn_us = boto.ec2.connect_to_region('us-east-1',aws_access_key_id='AKIAIWM7N2XR34NU6NQQ',aws_secret_access_key='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')

now = datetime.now()

today = now.date()

#DC-CB-AWS-04 volume description
dc_cb_AWS_04_vol_description = "DC-CB-AWS-04-%s" % today

#Create snapthot for DC-CB-AWS-04
conn_us.create_snapshot ("vol-2545d8c4", description=dc_cb_AWS_04_vol_description)


# calculate description two weeks from now:
two_weeks_ago = (today - timedelta(days=14))
dc_cb_AWS_04_vol_description_two_weeks_ago = "DC-CB-AWS-04-%s" % two_weeks_ago

# grab snapshot for first EBS volume 2 weeks ago, and delete it
two_weeks_ago_dc_cb_AWS_04_tuples_ = conn_us.get_all_snapshots(filters = {"description": dc_cb_AWS_04_vol_description_two_weeks_ago})
#grab snapshot-ID (since result is in list-of-tuples format)
try:
    two_weeks_ago_all_dc_cb_AWS_04_snapshot = two_weeks_ago_dc_cb_AWS_04_tuples[0]
    two_weeks_ago_all_dc_cb_AWS_04_snapshot_ID = two_weeks_ago_all_snapshot.id
#delete snapshot
    conn_eu.delete_snapshot(two_weeks_ago_all_dc_cb_AWS_04_snapshot_ID)
except:
    print "There is no snapshot two weeks ago to delete!"
