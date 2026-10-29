-module(brotli_decoder_test).

-include_lib("eunit/include/eunit.hrl").

used_on_any_input_test() ->
    Decoder = brotli_decoder:new(),
    brotli_decoder:stream(Decoder, <<11>>),
    ?assert(brotli_decoder:is_used(Decoder)).

not_used_on_empty_input_test() ->
    Decoder = brotli_decoder:new(),
    brotli_decoder:stream(Decoder, <<>>),
    ?assertNot(brotli_decoder:is_used(Decoder)).

finished_on_full_input_test() ->
    {ok, Encoded} = brotli:encode("test"),
    Decoder = brotli_decoder:new(),
    brotli_decoder:stream(Decoder, Encoded),
    ?assert(brotli_decoder:is_finished(Decoder)).

not_finished_on_partial_input_test() ->
    {ok, <<B, _Rest/binary>>} = brotli:encode("test"),
    Decoder = brotli_decoder:new(),
    brotli_decoder:stream(Decoder, <<B>>),
    ?assertNot(brotli_decoder:is_finished(Decoder)).


more_on_partial_input_test() ->
    {ok, Encoded} = brotli:encode(<<"test">>),
    Size = byte_size(Encoded),
    <<Head:(Size - 1)/binary, Last/binary>> = Encoded,
    Decoder = brotli_decoder:new(),
    ?assertMatch({more, _}, brotli_decoder:stream(Decoder, Head)),
    ?assertMatch({ok, _}, brotli_decoder:stream(Decoder, Last)).
