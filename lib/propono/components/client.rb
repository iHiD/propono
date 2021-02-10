module Propono
  class Client

    # Propono configuration.
    #
    # Settings should be set in an initializer or using some
    # other method that ensures they are set before any
    # Propono code is used.
    #
    # They can be set in one of the following ways:
    #
    # 1. As options passed to <tt>new</tt> as a hash.
    #
    #   Propono::Client.new(application_name: 'my-application')
    #
    # 2. As options passed to <tt>new</tt> using a block.
    #
    #   Propono::Client.new do |config"
    #     config.application_name: 'my-application'
    #   end
    #   
    # 3. By calling the <tt>Propono::Client#configure</tt>.
    #   client.configure do |config|
    #     config.access_key = "my-access-key"
    #   end

    attr_reader :config, :aws_client
    def initialize(settings = {}, &block)
      @config = Configuration.new
      if block_given?
        configure(&block)
      else
        settings.each do |key, value|
          config.send("#{key}=", value)
        end
      end

      @aws_client = AwsClient.new(AwsConfig.new(config))
    end

    def configure
      yield config
    end

    # Publishes a new message into the Propono pub/sub network.
    #
    # This requires a topic and a message. By default this pushes
    # out AWS SNS.
    #
    # @param [String] topic The name of the topic to publish to.
    # @param [String] message The message to post.
    def publish(topic, message, options = {})
      suffixed_topic = "#{topic}#{config.queue_suffix}"
      Publisher.publish(aws_client, config, suffixed_topic, message, options)
    end

    # Creates a new SNS-SQS subscription on the specified topic.
    #
    # This is implicitly called by {#listen}.
    #
    # @param [String] topic The name of the topic to subscribe to.
    def subscribe(topic)
      QueueSubscription.create(aws_client, config, topic)
    end

    # Listens on a queue and yields for each message
    #
    # Calling this will enter a queue-listening loop that
    # yields the message_processor for each messages.
    #
    # This method will automatically create a subscription if
    # one does not exist, so there is no need to call
    # <tt>subscribe</tt> in addition.
    #
    # @param [String] topic The topic to subscribe to.
    # @param &message_processor The block to yield for each message.
    def listen(topic_name, options = {}, &message_processor)
      QueueListener.listen(aws_client, config, topic_name, options, &message_processor)
    end

    # Listens on a queue and yields for each message
    #
    # Calling this will enter a queue-listening loop that
    # yields the message_processor for each messages.  The
    # loop will end when all messages have been processed.
    #
    # This method will automatically create a subscription if
    # one does not exist, so there is no need to call
    # <tt>subscribe</tt> in addition.
    #
    # @param [String] topic The topic to subscribe to.
    # @param &message_processor The block to yield for each message.
    def drain_queue(topic, &message_processor)
      QueueListener.drain(aws_client, config, topic, &message_processor)
    end
  end
end

