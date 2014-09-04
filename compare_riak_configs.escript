#!/usr/bin/env escript

main([FileA, FileB]) ->
	{ok, [TermsA]} = file:consult(FileA),
	{ok, [TermsB]} = file:consult(FileB),
	io:format("BOOM SHAKA LAKA: ~n~p~n", [props_diff(TermsA, TermsB)]);
	
main(Other) ->
	io:format("Do not understand ~p", [Other]).

props_diff(RProps, LProps) ->
  AllKeys = lists:usort(proplists:get_keys(RProps) ++ proplists:get_keys(LProps)),
	lists:foldl(fun(Key, Acc) ->
			           prop_or_list_diff(Key, RProps, LProps, Acc)
	            end,
							[],
							AllKeys).

prop_or_list_diff(Key, RProplist, LProplist, Acc) ->
  RList = get_prop_value_as_list(Key, RProplist),
	LList = get_prop_value_as_list(Key, LProplist),
  SampleKey = hd(RList ++ LList),
	Diffs = case SampleKey of
	  {_, [{_K,[{_SK,_SV}|_ST]}|_T]} -> props_diff(RList, LList);
		_      -> list_diff(RList, LList)
	end,
	case Diffs of
	  [] -> Acc;
		Diffs -> [{Key, Diffs} | Acc]
	end.


list_diff(RProps, LProps) ->
   RAcc = add_missing_props(RProps, LProps, []),
	 add_missing_props(LProps, RProps, RAcc).
	 
get_prop_value_as_list(Key, Proplist) ->
	 case proplists:get_value(Key, Proplist) of
	    undefined -> [];
			Props -> Props
	 end.

add_missing_props(Props1, Props2, Acc) ->
  case Props1 -- Props2 of
	  []    -> Acc;
		Diffs -> [Diffs | Acc]
	end.
