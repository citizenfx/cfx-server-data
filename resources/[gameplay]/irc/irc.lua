local reflection = clr.System.Reflection
local assembly = reflection.Assembly.LoadFrom('resources/[gameplay]/irc/ChatSharp.dll')

dofile('resources/[gameplay]/irc/irc_run.lua')