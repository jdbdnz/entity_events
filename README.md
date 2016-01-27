# EntityEvents

## ABOUT

Entity Events is a meta data collection tool which uses the MIT licence, written by Josh Dean on Chalkle.com time.

In a nutshell, it records whenever one entity interacts with another entity.

It could be criticized that Entity Events is doing the work of a third-party metrics service, which to some extent is valid. However I enjoy the flexibility, extensibility, and ownership of recording this myself alongside third-party metrics.

It is my long term goal to make a gem which will provide basic query functions for the data Entity Events records.

The design pattern was inspired by Pundit. 

This is the first gem I've published so please do contribute if you like the concept but feel you could do some things better.


## FUNCTIONALITY

Whenever a request is made an Interaction record is written to the database. An Interaction describes an 'actor' making an 'action' on a 'target'. This is usually the current_user, the controller action which the request is routed to, and the target the object the request is related to. 

i.e. { actor: User, action: Views, target: Post }

Additionally, all that request's params are stored in that interaction, as well as the controller and action names (for querying purposes), and also an option params[:flag] which I added so I could record which href a user used to get there.


## BASIC INSTALLATION

Steps 1-3 will have your rails app recording the Controller and Action for every Request. If the request is from an authenticated user, that user will be recorded. If entity_events can determine the target object from the params then that will also be recorded (i.e. On FooController Foo with id of 3 would be identified through params[:foo_id] or params[:id], in that order).


**1. Add entity_events to your gemfile then run bundle install**

`gem 'entity_events'`

**2. create and run a new migration**

```ruby
class CreateInteraction < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.string :action
      t.string :controller
      t.string :flag
      t.string :request_ip
      t.references :actor, polymorphic: true
      t.references :target, polymorphic: true
      t.timestamps
    end
  end
end
```

**3. On application_controller.rb**

```ruby
before_filter :entity_events

def entity_events
    auto_log = true
    EntityEvents.record(request, current_user, auto_log)
end
```


## CUSTOMIZATION

Maybe you don't want to record every single request, and you only want to record events on objects that you explicitly say to record. Revise the above ApplicationController code as follows.

**4. Recording events on a specific entity, rather than every entity**
```ruby
  before_filter :entity_events

  def entity_events
      auto_log = false
      EntityEvents.record(request, current_user, auto_log)
  end
```

Then, given that you want to record Foo events, you create a file at `/app/events/foo_events.rb`

```ruby
class FooEvent < EntityEvents::EntityEvent
  def should_record?
    true
  end
end
```


Let's say you care when a Foo is Created, but not when someone requests the new Foo form. Do the following

**5. Recording specific events on specific entities, rather than every event**

```ruby
class FooEvent < EntityEvents::EntityEvent
  def new?
    false
  end

  def create?
    true
  end
end
```


entity_events does a very basic job of getting the actor and target; it says the actor is the authenticated_user, and the target is object of type params[:controller] with an id of params[:<object>_id] or params[:id]

In this sample, users belong to a group and a Foo has many Bars. Because we care how many bars a group of users make on any given Foo, we want to record the actor as the Group and the target as the Foo. You can do that!

**6. Unconventional actors and targets**

```ruby
class BarEvent < EntityEvents::EntityEvent
  def new_actor
    current_user.group
  end

  def new_target
    id = params[:foo_id]
    Foo.find id
  end
end
```

Lets say you are analyzing user behavior. There are two buttons to create a new Bar, and you want to see which button people people use more to get to the new Bar form. So long as you are recording the new Bar action, it is as simple as setting the params[:flag] on the button as follows 

**7. Indicators**

```ruby
<a id="new_bar_a" href="<%= new_bar_path({flag: 'a'}) %>" />
<a id="new_bar_b" href="<%= new_bar_path({flag: 'b'}) %>" />
```

Maybe you think params[:flag] is ugly though, or perhaps you are already using it for something else, then you will want to override flag in your EntityEvent file to record params[:xyz]. You could do this on each file, as in overriding it on foo_event.rb and bar_event.rb. But if you want to make it normalized throughout your app it would be far simpler to create a new base EntityEvent which FooEvent and BarEvent would inherit from

```ruby
class CustomEntityEvent < EntityEvents::EntityEvent
  def flag
    params[:xyz]
  end
end
```

```ruby
class FooEvent < CustomEntityEvent
  ##
  #I inherit flag from CustomEntityEvent so I don't need to implement it myself in order to receive params[:xyz]
  ##
end
```

If you really want you can override controller, action, flag, default_actor, and default_target on your CustomEntityEvent or on a entity by entity basis (i.e. just for Foo entity in the FooEvent class)

**8. Other overrides**

```ruby
class CustomEntityEvent < EntityEvents::EntityEvent
  def default_actor
    current_user.group
  end
end
```



TESTS

coming soon...
