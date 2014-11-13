%% @author Taotaotheripper <taotaotheripper@gmail.com>
%% @copyright 2014 UNIAS.
%%
%% @doc dpmd - Docker port mapping daemon. Docker port mapping service which
%% can map Erlang node name or a specific port to its published host port
%% in distributed docker cluster.
%%
%% Kernel Environment Configuration:
%%  * {docker_daemon_port, Port::integer()} - Docker HTTP Port in the distributed
%%  docker cluster.
%%	* {erlang_port, Port::integer()} - Erlang TCP Port listening.
%% These configuration should be set in the environment values of Kernel application
%% or else default values will be used.
%% 
%% For example:
%%		erl -kernel docker_daemon_port xxxx erlang_port xxxx

-module(dpmd).
-author('taotaotheripper@gmail.com').
-export([node_to_port/1, port_please/3, is_valid_node/1]).

-include("eid_ports.hrl").

-define(DPMD_HTTPC_PROFILE, dpmd_httpc).
-define(REQUEST_URL, "http://~s:~w/containers/~s/json").
-define(NETWORKSETTING_KEY, <<"NetworkSettings">>).
-define(PORTINFO_KEY, <<"Ports">>).
-define(HOSTPORT_KEY, <<"HostPort">>).

%%%----------------------------------------------------------------------
%%% API
%%%----------------------------------------------------------------------

%% @doc Fetch published port number of Erlang on Node.
%% Names of all nodes in the system are guaranteed to be 'CID@IP',
%% and they all listen on port ?DEFAULT_ERLANG_PORT.
%% * CID: Container ID
%% * IP: Host IP
-spec node_to_port(Node::node()) -> {ok, Port::integer()} | {error, Reason::term()}.
node_to_port(Node) -> 
	{ok, {CID, IP}} = extract_CID_IP(Node),
	Port = ?ERLANG_PORT(),
	port_please(IP, CID, Port).

%% @doc Fetch published host port mapping to Port in Container CID.
%% * IP: HOST IP
%% * CID: Container ID
%% * Port: Port in Container.
-spec port_please(IP::string()|atom(), CID::string()|atom(), Port::integer()) ->
	{ok, PublishedPort::integer()} | {error, Reason::term()}.
port_please(IP, CID, Port) when is_atom(IP) ->
	port_please(atom_to_list(IP), CID, Port);
port_please(IP, CID, Port) when is_atom(CID) ->
	port_please(IP, atom_to_list(CID), Port);
port_please(IP, CID, Port) ->
	ensure_httpc(),
	DockerPort = ?DOCKER_PORT(),
	Url = format_url(IP, DockerPort, CID),
	%% Causion: Profile for httpc is not well handled. We must use pid instead.
	%% Reference - http://erlang.org/doc/apps/inets/notes.html
	%% Use erlang:register/1 and erlang:whereis/1.
	%%
	%% 2014-11-10 We use inet mode instead, so there is no problem above any more.
	%% However, the annotation is informative, so I didn't remove it.
	case httpc:request(Url, ?DPMD_HTTPC_PROFILE) of
		{ok, Res} ->
			PortKey = port_key(Port),
			case parse_response(Res, PortKey) of
				{ok, Port} ->
					{ok, Port};
				Error ->
					Error
			end;
		Error ->
			Error
	end.

%% @doc Check whether Node is a valid node name.
%% Valid node name format - 'CID@IP'
-spec is_valid_node(Node::atom()) -> true | false.
is_valid_node(Node) ->
	case catch extract_CID_IP(Node) of
		{ok, {_CID, _IP}} -> true;
		_Invalid -> false
	end.

%%%----------------------------------------------------------------------
%%% Internal Functions
%%%----------------------------------------------------------------------

ensure_httpc() ->
	application:start(inets),
	inets:start(httpc, [{profile, ?DPMD_HTTPC_PROFILE}]).

parse_response(Res, PortKey) ->
	{_Status, _Headers, Body} = Res,
	case catch mochijson2:decode(Body) of
		{'EXIT', _Reason} ->
			{error, {bad_json, Body}};
		ContainerInfo ->
			JsonObj = mochijson2:jsonobj(ContainerInfo),
			case catch
				((((JsonObj(?NETWORKSETTING_KEY))(?PORTINFO_KEY))(PortKey))(1))(?HOSTPORT_KEY)
				of
				{'EXIT', _Reason} ->
					{error, {port_mapping_not_found, PortKey}};
				HostPortKey ->
					{ok, list_to_integer(binary_to_list(HostPortKey))}
			end
	end.

extract_CID_IP(Node) ->
	NodeStr = atom_to_list(Node),
	[CID, IP] = string:tokens(NodeStr, "@"),
	{ok, {CID, IP}}.

format_url(IP, DockerPort, CID) ->
	lists:flatten(io_lib:format(?REQUEST_URL, [IP, DockerPort, CID])).

port_key(Port) ->
	PortKeyStr = integer_to_list(Port) ++ "/tcp",
	list_to_binary(PortKeyStr).
