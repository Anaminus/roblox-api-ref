# Summary
A **RemoteFunction** creates an interface to a function, which may then be
called from another peer.

# Details
RemoteFunctions enable a function to be called from another peer. This is done
by replicating the arguments of a call on one peer to another peer, then
replicating the return values back. Functions are yielded to ensure
synchronicity.

RemoteFunctions are generally used for requesting data, since they enable a
peer to send values, and receives values back. If you need to send data to
another peer, but don't require a response, you should use
[RemoteEvents](RemoteEvent.html).

Here's an example that uses InvokeClient and OnClientInvoke:

The client:

	name = 'Alice'

	function RemoteFunction.OnClientInvoke( player, query )
		if query == 'What is your name?' then
			print("Server asked me for my name")

			local response = 'My name is ' .. name
			return response
		end
	end

The server:

	query = 'What is your name?'

	response = RemoteFunction:InvokeClient( Game.Players.Player1, query )
	name = response:match('^My name is (.-)$')
	print("Client's name is " .. name)

Here's an example that uses InvokeServer and OnServerInvoke:

The server:

	function RemoteFunction.OnServerInvoke( player, query )
		if query == 'Can you give me a list of players?' then
			print("Client " .. player.Name .. " didn't say please")
			return false

		elseif query == 'Can you give me a list of players, please?' then
			print("Client " .. player.Name .. " asked for a list of players")

			local list = Game.Players:GetPlayers()
			return list
		end
	end

The client:

	query = 'Can you give me a list of players?'

	list = RemoteFunction:InvokeServer( query )
	if list then
		print("List of players:"")
		for i = 1,#list do
			print("-", list[i])
		end

	else
		print("Server did not give me what I asked for. Now he must die."")
	end

# Members

## InvokeClient
Invokes the [OnClientInvoke](#memberOnClientInvoke) callback on a particular
client. The target client is indicated by the *player* argument, which should
be a [Player](Player.html) object. Note that this calls the OnClientInvoke
that was defined on the targeted client, and not on the server, or some other
client.

*arguments* are the values that will be replicated to the client, and then
passed to OnClientInvoke. The values returned by OnClientInvoke will be
replicated back to the server, and then returned by InvokeClient.

InvokeClient will yield until OnClientInvoke returns. If OnClientInvoke was
not defined after InvokeClient was called, then the RemoteFunction will wait
until it is defined, and then call it as usual.

If OnClientInvoke throws an error, that error will be replicated back, and
thrown by InvokeClient. Note that this includes the entire error message, with
information about the script, and the line where the error occurred.

This function cannot be called on a client; it may be called only by the
server.

## InvokeServer
Invokes the [OnServerInvoke](#memberOnServerInvoke) callback on the server.
Note that this is the OnServerInvoke defined on the server, and not the
current client, or some other client.

*arguments* are the values that will be replicated to the server, and then
passed to OnServerInvoke. The values returned by OnServerInvoke will be
replicated back to the client, and then returned by InvokeServer.

InvokeServer will yield until OnServerInvoke returns. If OnServerInvoke was
not defined after InvokeServer was called, then the RemoteFunction will wait
until it is defined, and then call it as usual.

If OnServerInvoke throws an error, that error will be replicated back, and
thrown by InvokeServer. Note that this includes the entire error message, with
potentially sensitive information about the script, and the line where the
error occurred. If you do not want this information to be leaked to the
client, then ensure that OnServerInvoke will not throw an error.

This function cannot be called on the server; it may be called only by a
client.

## OnClientInvoke
OnClientInvoke is called after [InvokeClient](#memberInvokeClient) is called
on the server, with the current client as its target.

*arguments* are the values that were passed to InvokeClient, and then
replicated to the client. The values returned by OnClientInvoke will be
replicated back to the server, and then returned by InvokeClient.

If OnClientInvoke is defined sometime after InvokeClient was called, then
OnClientInvoke will be called immediately. OnClientInvoke is allowed to yield.

The server is allowed to set this callback. However, it will never be called,
since InvokeClient cannot be called from a client, and there are no means for
InvokeClient to target the server.

## OnServerInvoke
OnServerInvoke is called after [InvokeServer](#memberInvokeServer) is called
from a client. **player** indicates a [Player](Player.html) object that
corresponds to the client.

*arguments* are the values that were passed to InvokeServer, and then
replicated to the server. The values returned by OnServerInvoke will be
replicated back to the client, and then returned by InvokeServer.

If OnServerInvoke is defined sometime after InvokeServer was called, then
OnServerInvoke will be called immediately. OnServerInvoke is allowed to yield.

Clients are allowed to set this callback. However, it will never be called,
since InvokeServer cannot be called from the server, and there are no means
for InvokeServer to target a client.
