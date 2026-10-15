---
sidebar_position: 8
---

# Callbacks

Override any of these in the crawler to hook into the run. Callbacks are called
on a new crawler instance without a response.

```ruby
class MyScraper < Vessel::Cargo
  def before_start; end              # before anything is scheduled
  def before(stats); end             # with the initial stats
  def after_change(counter, stats)   # on every stats counter change
  end
  def info(stats); end               # every 4 seconds, logs the stats by default
  def after(stats); end              # when the engine is done
  def before_stop; end               # at exit
  def on_error(request, error); end  # a request failed, re-raises by default
end
```

#### before_start

Called before anything is scheduled.

#### before(stats)

Called with the initial [stats](#stats).

#### after_change(counter, stats)

Called on every stats counter change with the name of the counter. It's called
a lot, keep it fast.

#### info(stats)

Called every 4 seconds and at exit, logs the stats by default.

#### after(stats)

Called when the engine is done.

#### before_stop

Called at exit.

#### on_error(request, error)

Called when a request failed after all the
[attempts](/docs/vessel/settings#network_error_attemptsvalue). Re-raises the
error by default, which is then logged by the engine and the crawler goes on.

```ruby
class MyScraper < Vessel::Cargo
  def on_error(request, error)
    Vessel::Logger.warn("Failed #{request.url}: #{error.message}")
  end
end
```

## Stats

The stats hash holds:

* `req_enqueued` - requests scheduled
* `res_dequeued` - responses taken by the engine
* `res_handled` - responses handled by a handler
* `item_pipelined` - items sent to the middleware
* `item_processed` - items that went through the middleware
* `item_sent` - items accepted by the middleware
* `item_rejected` - items rejected by the middleware
* `idling` - whether the engine has nothing to do
