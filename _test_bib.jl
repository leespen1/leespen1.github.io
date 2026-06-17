text = read("CV/SpencerLeeBibliography.bib", String)
# Check what the regex captures for LeeHOHO
m = match(r"@article\{LeeHOHO,\s*(.*?)\n\}"s, text)
if m === nothing
    println("No match for LeeHOHO!")
    # Try broader match
    for m2 in eachmatch(r"@(\w+)\{([^,]+),\s*(.*?)\n\}"s, text)
        println("Found: ", m2.captures[2])
    end
else
    body = m.captures[1]
    println("Body: ", body)
    # Get url field
    fm = match(r"url\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}", body)
    if fm !== nothing
        println("URL: ", fm.captures[1])
    else
        println("No url field matched!")
    end
end
