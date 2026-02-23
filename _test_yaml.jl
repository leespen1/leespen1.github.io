using YAML

function latex_to_html(s::String)
    umlaut = Dict("a"=>"ä","e"=>"ë","i"=>"ï","o"=>"ö","u"=>"ü",
                   "A"=>"Ä","E"=>"Ë","I"=>"Ï","O"=>"Ö","U"=>"Ü")
    acute  = Dict("a"=>"á","e"=>"é","i"=>"í","o"=>"ó","u"=>"ú",
                   "A"=>"Á","E"=>"É","I"=>"Í","O"=>"Ó","U"=>"Ú")
    s = replace(s, r"\\\\\"(\w)" => function(m)
        ch = string(last(m))
        get(umlaut, ch, ch)
    end)
    s = replace(s, r"\\'\{(\w)\}" => function(m)
        ch = string(m[end-1])
        get(acute, ch, ch)
    end)
    s = replace(s, r"\\'(\w)" => function(m)
        ch = string(last(m))
        get(acute, ch, ch)
    end)
    s = replace(s, "--" => "&ndash;")
    return s
end

data = YAML.load_file("CV/experience.yaml")

tests = [
    (data[1]["description"], "Appelö", "Umlaut in description"),
    (data[1]["items"][2], "Schrödinger", "Umlaut in item"),
    (data[4]["items"][3], "Poincaré", "Acute accent"),
    (data[6]["items"][2], "Störmer", "Umlaut Störmer"),
    (data[1]["dates"], "&ndash;", "En-dash"),
]

all_pass = true
for (input, expected, label) in tests
    result = latex_to_html(input)
    if occursin(expected, result)
        println("PASS: $label")
    else
        println("FAIL: $label")
        println("  Result: $result")
        global all_pass = false
    end
end

println(all_pass ? "\nAll tests passed!" : "\nSome tests failed!")
