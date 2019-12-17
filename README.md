Currently this script does the following:

## Reading from Things.app
- Reads tasks from today view in Things

## Sorting
- Groups task types together, i.e. errands, focussed work etc. Because
obviously I want to do all my phone-calls, emails etc. at the same time, and
order by the usual order I do things in (chores, focussed work, errands
...) 
- Group any tasks that have been given a time of day tag. i.e. If a task
has to be done in the morning I tag it "when:morning", it groups all of these
together
- Make sure all tasks are grouped by task type within their time of
day grouping, i.e. make sure all my morning-errands are grouped together
- Order the tasks within task type groups by importance, i.e. most important
errand goes first - Order the groups of tasks ordered by type by group
importance. i.e. If I have a bunch of errands to do, and a bunch of admin,
given I have a very important errand in the errand group, then the whole
errand group comes before admin.

## Publishes Data
- Publishes data to a Gist as JSON so it can be used by Siri Shortcuts
