# Propono
#
# Propono is a pub/sub gem built on top of Amazon Web Services (AWS). It uses Simple Notification Service (SNS) and Simple Queue Service (SQS) to seamlessly pass messages throughout your infrastructure.
require "propono/version"
require 'propono/propono_error'
require 'propono/logger'
require 'propono/configuration'
require "propono/utils"

require 'propono/components/client'

require 'propono/components/aws_config'
require 'propono/components/aws_client'

require "propono/components/queue"
require "propono/components/topic"
require "propono/components/queue_subscription"
require "propono/components/sqs_message"

require "propono/services/publisher"
require "propono/services/queue_listener"

# Propono is a pub/sub gem built on top of Amazon Web Services (AWS).
# It uses Simple Notification Service (SNS) and Simple Queue Service (SQS)
# to seamlessly pass messages throughout your infrastructure.
module Propono
end
