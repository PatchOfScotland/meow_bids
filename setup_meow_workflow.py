
import os
import shutil
import socket
import time

from grp import getgrnam
from pwd import getpwnam

from meow_base.core.runner import MeowRunner
from meow_base.core.vars import DIR_CREATE_EVENT, DIR_MODIFY_EVENT, \
    DIR_RETROACTIVE_EVENT, NOTIFICATION_EMAIL, NOTIFICATION_MSG, \
    DEFAULT_JOB_OUTPUT_DIR, DEFAULT_JOB_QUEUE_DIR
from meow_base.conductors import LocalBashConductor, LocalPythonConductor
from meow_base.patterns import FileEventPattern, WatchdogMonitor
from meow_base.recipes import BashRecipe, BashHandler, PythonRecipe, PythonHandler
from meow_base.functionality.file_io import read_file_lines, make_dir, rmtree
from meow_base.functionality.meow import assemble_patterns_dict, \
    assemble_recipes_dict

base_dir =       "meow"
raw_dir =        "raw"
validating_dir = "validating"
analysing_dir =  "analysing"
user_dir =       "user"
result_dir =     "result"

dataset = "martin_mri"

raw_files = {
    "sub-01": (["3", "5", "8"], []),
    "sub-02": (["3", "5"], ["8"]),
    "sub-03": ([], ["3", "5", "8"]),
}

copy_delay = 15

if socket.gethostname() == "macavity":
    datastore = "/home/patch/Documents/Research/Datasets"
    experiment_dir = "/home/patch/Documents/Research/Python"
    analysis_recipe = "recipes/dummy_analysis.sh"
else:
    datastore = "/data"
    experiment_dir = "/home/patch"
    analysis_recipe = "recipes/analysis.sh"

uid = getpwnam('patch').pw_uid
gid = getgrnam('patch')[2]

for r in [ "job_output", "job_queue", base_dir ]:
    if os.path.exists(r):
        os.chown(r, uid, gid)
        rmtree(r)

for d in [ raw_dir, validating_dir, analysing_dir, user_dir, result_dir ]:
    p = os.path.join(base_dir, d)
    make_dir(p, can_exist=True)

# Only load first two sessions, the last will be added later
for subject, files in raw_files.items():
    for t in files[0]:
        target = os.path.join(base_dir, raw_dir, dataset, subject, t)
        make_dir(target, can_exist=True)
        shutil.copytree(
            os.path.join(datastore, "MRI_data", "sourcedata", t),
            target,
            dirs_exist_ok=True
        )

# Automatic conversion of bids data
p_convert = FileEventPattern(
    "conversion_pattern",
    os.path.join(raw_dir, "*", "*", "*"),
    "conversion_recipe",
    "input_base",
    parameters={
        "output_base": os.path.join(experiment_dir, "meow_bids",  base_dir, validating_dir),
    },
    event_mask=[
        DIR_CREATE_EVENT,
        DIR_MODIFY_EVENT,
        DIR_RETROACTIVE_EVENT
    ]
)
r_convert = BashRecipe(
    "conversion_recipe", 
    read_file_lines("recipes/conversion.sh")
)

# Automatic validation of bids data
p_validate = FileEventPattern(
    "validation_pattern",
    os.path.join(validating_dir, dataset),
    "validation_recipe",
    "validating_dir",
    parameters={
        "analysing_dir": os.path.join(base_dir, analysing_dir),
        "user_dir": os.path.join(base_dir, user_dir),
        "dataset": dataset
    },
    event_mask=[
        DIR_CREATE_EVENT,
        DIR_RETROACTIVE_EVENT
    ]
)
r_validate = BashRecipe(
    "validation_recipe",
    read_file_lines("recipes/validation.sh")
)

# Notify user of invalid bids conversion
p_notify = FileEventPattern(
    "notification_pattern",
    user_dir + "/*/README",
    "notification_recipe",
    "user_dir",
    notifications={
        NOTIFICATION_EMAIL: "user@localhost",
        NOTIFICATION_MSG: "A bids workflow requires attention at {DIR}."
    }
)
r_notify = BashRecipe(
    "notification_recipe",
    read_file_lines("recipes/notification.sh")
)

# Conduct analysis on valid bids input
p_analysis = FileEventPattern(
    "analysis_pattern",
    analysing_dir + "/*/README",
    "analysis_recipe",
    "user_dir",
    parameters={
        "analysing_dir": os.path.join(base_dir, analysing_dir, dataset),
        "result_dir": os.path.join(base_dir, result_dir),
        "dataset": dataset,
        "base": "/home/patch/meow_bids"
    }
)
r_analysis = BashRecipe(
    "analysis_recipe",
    read_file_lines(analysis_recipe)
)

# Notify user of complete analysis
p_complete = FileEventPattern(
    "completion_pattern",
    result_dir + "/*/README",
    "notification_recipe",
    "analysing_dir",
    notifications={
        NOTIFICATION_EMAIL: "user@localhost",
        NOTIFICATION_MSG: "Analyis complete for bids data at {DIR}."
    }
)

patterns = assemble_patterns_dict(
    [ 
        p_convert, 
        p_validate, 
        p_notify, 
        p_analysis,
        p_complete,
    ]
)

recipes = assemble_recipes_dict(
    [ 
        r_convert, 
        r_validate, 
        r_notify, 
        r_analysis
    ]
)

runner = MeowRunner(
    WatchdogMonitor(
        base_dir,
        patterns,
        recipes, 
        logging=3
    ),
    BashHandler(
        pause_time=1
    ),
    LocalBashConductor(
        pause_time=1,
        notification_email="alert@localhost",
        notification_email_smtp="localhost:1025"
    )
)

runner.start()

for subject, files in raw_files.items():
    for t in files[1]:
        time.sleep(copy_delay)

        target = os.path.join(base_dir, raw_dir, dataset, subject, t)
        make_dir(target, can_exist=True)
        shutil.copytree(
            os.path.join(datastore, "MRI_data", "sourcedata", t),
            target,
            dirs_exist_ok=True
        )

idle_count = 0
completed_jobs = -1
while idle_count < 30:
    if (len(os.listdir(DEFAULT_JOB_QUEUE_DIR)) == 0) and (completed_jobs == len(os.listdir(DEFAULT_JOB_OUTPUT_DIR))) :
        idle_count += 1
    else:
        idle_count = 0
    completed_jobs = len(os.listdir(DEFAULT_JOB_OUTPUT_DIR))

    time.sleep(1)

runner.stop()
