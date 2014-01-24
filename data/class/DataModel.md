# Summary

The **DataModel** class represents the root of the game hierarchy and the game itself. It contains all the game services and is a service provider because of this.

# Details

All instances of ROBLOX games contain a [singleton][Singleton pattern] DataModel object which does not replicate and gives access to all the game services. The DataModel object can be accessed by scripts with the `game` variable or with the `Game` variable. These two variables are part of the global environment. The DataModel object provides many members related to the game itself. Those are particularly useful to get information about the game; examples of such members are the [PlaceId](#memberPlaceId) and [CreatorId](#memberCreatorId) properties.

# Members

## CreatorId

This is the identifier of the user who owns the place. In offline games, this property has the value 0.

## CreatorType

This indicates whether the place belongs to a user or to a group. Group places are not used anymore and this property is not very useful anymore, although group places still exist. They are now difficult to find and cannot be used.

## GearGenreSetting

This indicates whether gear that can be used in the game is restricted to gear that match the game's genre or not.

## Genre

This is the genre of the place.

## IsPersonalServer

This indicates whether the game is a personal server.

## JobId

This is an identifier unique to the current game server. It can be used to identify the game server externally, for example when servers are communicating with a web server using [HttpService](HttpService.html). Example: `74829c09-ef44-483b-bdda-138bbd704f4b`.

## PlaceId

This is the identifier of the place to which the game server belongs. It is 0 in offline games.

## PlaceVersion

This is the version of the current place. It corresponds to the version number given in the version history configuration page of the place, and is incremented of 1 each time the game is updated. It can be used to compare the recency of servers that need to communicate with a web server using [HttpService](HttpService.html).

## Workspace

This is a reference to the workspace service.

[Singleton pattern]: https://en.wikipedia.org/wiki/Singleton_pattern
