-module(chatterbox_ranch_protocol).

-include("http2_socket.hrl").
%%-behaviour(ranch_protocol).

-export([
         start_link/4,
         init/4
        ]).

start_link(Ref, Socket, Transport, Opts) ->
    proc_lib:start_link(?MODULE, init, [Ref, Socket, Transport, Opts]).

init(Ref, Socket, T, _Opts) ->
    ok = proc_lib:init_ack({ok, self()}),
    ok = ranch:accept_ack(Ref),
    http2_socket:become({transport(T), Socket}).

transport(ranch_ssl) ->
    ssl;
transport(ranch_tcp) ->
    gen_tcp;
transport(tcp) ->
    gen_tcp;
transport(gen_tcp) ->
    gen_tcp;
transport(ssl) ->
    ssl;
transport(Other) ->
    lager:error("chatterbox_ranch_protocol doesn't support ~p", [Other]),
    error(unknown_protocol).
