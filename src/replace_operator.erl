%%%
%%% Copyright (c) 2012, Nicolas Charpentier, Diana Corbacho & Erlang Solutions Ltd.
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in the
%%%       documentation and/or other materials provided with the distribution.
%%%     * Neither the name of the <organization> nor the
%%%       names of its contributors may be used to endorse or promote products
%%%       derived from this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%%% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
%%% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%%% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%%% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%%% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%%% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%

-module(replace_operator).

-export([mutate/1]).

mutate(Forms) ->
    {R,[]} = mt_utils:fold(fun mutate_fun/2,
			   [],
			   Forms),
    R.

mutate_fun({op,_,_,_,_} = Candidate, State) ->
    case mutate_op(Candidate) of
	[] ->
	    {nothing, State};
	NewElt ->
	    {replace, NewElt, State}
    end.

mutate_op({op,V1,Op,V2,V3}) ->
    Base =
	try
	    [{op,V1,new_op(Op),V2,V3}]
	catch
	    _:_ ->
		[]
	end,
    MutV2 = mutate_op(V2),
    MutV3 = mutate_op(V3),
    Base ++ [{op,V1,Op,MV2,V3} || MV2 <- MutV2]
	++ [{op,V1,Op,V2,MV3} || MV3 <- MutV3];
mutate_op(_) ->
    [].

new_op('+') ->
    '-';
new_op('-') ->
    '+';
new_op('*') ->
    '/';
new_op('/') ->
    '*'.



