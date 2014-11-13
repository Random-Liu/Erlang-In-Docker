%% @author Taotaotheripper <taotaotheripper@gmail.com>
%% @copyright 2014 UNIAS.
%%
%% @doc Default port number and functions for dpmd.erl and edi_tcp_dist.erl.

-define(DOCKER_PORT_KEY, erlang_daemon_port). %% Docker Daemon Port Key in Kernel Environment
-define(ERLANG_PORT_KEY, erlang_port). %% Erlang Port Key in Kernel Environment
-define(DEFAULT_DOCKER_PORT, 4243). %% Default Docker Daemon HTTP Port
-define(DEFAULT_ERLANG_PORT, 12345). %% Default Erlang VM TCP Port

%% Use "_" to avoid conflict with the variable out of the macro.
-define(PORT(_Key, _Default),
	case application:get_env(kernel, _Key) of
		{ok, _Port} when is_integer(_Port) ->
			_Port;
		{ok, _InvalidArg} ->
			error_logger:error_msg("** Invalid ~p Value: ~p~n **", [_Key, _InvalidArg]),
			_Default;
		undefined ->
			_Default
	end).

-define(ERLANG_PORT(), ?PORT(?ERLANG_PORT_KEY, ?DEFAULT_ERLANG_PORT)).
-define(DOCKER_PORT(), ?PORT(?DOCKER_PORT_KEY, ?DEFAULT_DOCKER_PORT)).
