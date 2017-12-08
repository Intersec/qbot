#!/bin/sh

# Mandatory:
#
# API token for the bot entity

export HUBOT_SLACK_TOKEN=

# Redis URL for data saving/reloading

export REDIS_URL=

#
# Optional:
#

# set the log level, use debug for useful logs :)

export HUBOT_LOG_LEVEL=

# If set to 1, notifications are sent in DMs to the notified people.
# Otherwise, notifications are redirected on the channel #qbot-dev

export QBOT_PROD_READY=
