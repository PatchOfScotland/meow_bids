
import os
import shutil

from meow_base.core.runner import MeowRunner
from meow_base.core.vars import DIR_CREATE_EVENT, DIR_MODIFY_EVENT, \
    DIR_RETROACTIVE_EVENT, NOTIFICATION_EMAIL, NOTIFICATION_MSG
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

start_copy = ["3"]
ongoing_copy = ["5", "8"]
copy_delay = 15

for r in [ "job_output", "job_queue", base_dir ]:
    rmtree(r)

for d in [ raw_dir, validating_dir, analysing_dir, user_dir, result_dir ]:
    p = os.path.join(base_dir, d)
    make_dir(p, can_exist=True)

# Only load first two sessions, the last will be added later
for t in start_copy:
    target = os.path.join(base_dir, raw_dir, dataset, t)
    make_dir(target, can_exist=True)
    shutil.copytree(
        f"/home/patch/Documents/Research/Datasets/MRI_data/sourcedata/{t}", 
        target,
        dirs_exist_ok=True
    )

# Automatic conversion of bids data
p_convert = FileEventPattern(
    "conversion_pattern",
    os.path.join(raw_dir, "*", "*"),
    "conversion_recipe",
    "input_base",
    parameters={
        "output_base": os.path.sep + os.path.join("home", "patch", "Documents", "Research", "Python", "meow_bids",  base_dir, validating_dir),
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
    notifications={
        NOTIFICATION_EMAIL: "user@localhost",
        NOTIFICATION_MSG: "Analyis in bids data at {DIR}."
    }
)
r_analysis = BashRecipe(
    "analysis_recipe",
    read_file_lines("recipes/notification.sh")
)

patterns = assemble_patterns_dict(
    [ 
        p_convert, 
        p_validate, 
        p_notify, 
        p_analysis 
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
        logging=4
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

import time
time.sleep(copy_delay)

for t in ongoing_copy:
    target = os.path.join(base_dir, raw_dir, dataset, t)
    make_dir(target, can_exist=True)
    shutil.copytree(
        f"/home/patch/Documents/Research/Datasets/MRI_data/sourcedata/{t}", 
        target,
        dirs_exist_ok=True
    )

    time.sleep(copy_delay)


print(runner.monitors[0].get_rules())

print(len(runner.event_queue))

runner.stop()
