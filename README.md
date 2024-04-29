# analytics-elixir ![analytics-elixir](https://github.com/FindHotel/analytics-elixir/workflows/analytics-elixir/badge.svg?branch=master)

analytics-elixir is a non-supported third-party client for [Segment](https://segment.com)

## Installation

Add the following to deps section of your mix.exs:

```elixir
{:segment, github: "FindHotel/analytics-elixir"}
```

And then run:

```sh
mix deps.get
```

## Usage

For general usage, first define the `:key` configuration:

```elixir
config :segment, key: "your_segment_key"
```

> For detailed information about configuration, see `t:Segment.options/0`.

Then call `Segment.Analytics` functions to send analytics.

There are then two ways to call the functions:

- By using a collection of parameters
- By using the related struct as a parameter

### Track

```elixir
Segment.Analytics.track(user_id, event, %{property1: "", property2: ""})
```

or the full way using a struct with all the possible options for the track call

```elixir
%Segment.Analytics.Track{ userId: "sdsds",
                          event: "eventname",
                          properties: %{property1: "", property2: ""}
                        }
  |> Segment.Analytics.track
```

### Identify

```elixir
Segment.Analytics.identify(user_id, %{trait1: "", trait2: ""})
```

or the full way using a struct with all the possible options for the identify call

```elixir
%Segment.Analytics.Identify{ userId: "sdsds",
                             traits: %{trait1: "", trait2: ""}
                           }
  |> Segment.Analytics.identify
```

### Screen

```elixir
Segment.Analytics.screen(user_id, name)
```

or the full way using a struct with all the possible options for the screen call

```elixir
%Segment.Analytics.Screen{ userId: "sdsds",
                           name: "dssd"
                         }
  |> Segment.Analytics.screen
```

### Alias

```elixir
Segment.Analytics.alias(user_id, previous_id)
```

or the full way using a struct with all the possible options for the alias call

```elixir
%Segment.Analytics.Alias{ userId: "sdsds",
                          previousId: "dssd"
                         }
  |> Segment.Analytics.alias
```

### Group

```elixir
Segment.Analytics.group(user_id, group_id)
```

or the full way using a struct with all the possible options for the group call

```elixir
%Segment.Analytics.Group{ userId: "sdsds",
                          groupId: "dssd"
                         }
  |> Segment.Analytics.group
```

### Page

```elixir
Segment.Analytics.page(user_id, name)
```

or the full way using a struct with all the possible options for the page call

```elixir
%Segment.Analytics.Page{ userId: "sdsds",
                         name:   "dssd"
                       }
  |> Segment.Analytics.page
```

## Testing

Clone the repository and run:

```sh
mix test
```

## Release

After merge a new feature/bug you can bump the version and push it to upstream:

```sh
make release
git push origin master && git push origin --tags
```
