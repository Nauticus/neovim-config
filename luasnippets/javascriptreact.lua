local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
    s(
        { trig = "react-use-effect", name = "React useEffect hook" },
        fmt([[
        {}useEffect(() => {{
            {}
        }}, [{}]);
        ]], {
            c(1, {
                t(""),
                t("React."),
            }),
            i(2),
            i(3),
        })
    ),
}
