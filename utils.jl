using YAML

# ==============================================================================
# CV Helper Functions
# ==============================================================================

"""Convert LaTeX accent commands and special characters to Unicode."""
function latex_to_html(s::String)
    umlaut = Dict("a"=>"ä","e"=>"ë","i"=>"ï","o"=>"ö","u"=>"ü",
                   "A"=>"Ä","E"=>"Ë","I"=>"Ï","O"=>"Ö","U"=>"Ü")
    acute  = Dict("a"=>"á","e"=>"é","i"=>"í","o"=>"ó","u"=>"ú",
                   "A"=>"Á","E"=>"É","I"=>"Í","O"=>"Ó","U"=>"Ú")
    # \"o -> ö  (umlaut)
    s = replace(s, r"\\\\\"(\w)" => function(m)
        ch = string(last(m))
        get(umlaut, ch, ch)
    end)
    # \'{e} -> é  (acute with braces)
    s = replace(s, r"\\'\{(\w)\}" => function(m)
        ch = string(m[end-1])
        get(acute, ch, ch)
    end)
    # \'e -> é  (acute without braces)
    s = replace(s, r"\\'(\w)" => function(m)
        ch = string(last(m))
        get(acute, ch, ch)
    end)
    # \& -> &
    s = replace(s, "\\&" => "&amp;")
    # -- -> en-dash (use HTML entity so Franklin doesn't interfere)
    s = replace(s, "--" => "&ndash;")
    return s
end

"""Parse the experience.yaml file and render as HTML."""
function hfun_cv_experience()
    data = YAML.load_file("CV/experience.yaml")
    io = IOBuffer()
    for entry in data
        dates = latex_to_html(get(entry, "dates", ""))
        title = latex_to_html(get(entry, "title", ""))
        org = latex_to_html(get(entry, "org", ""))
        location = latex_to_html(get(entry, "location", ""))
        description = latex_to_html(get(entry, "description", ""))
        items = [latex_to_html(i) for i in get(entry, "items", [])]

        write(io, """<div class="cv-entry">\n""")
        write(io, """<div class="cv-entry-header">\n""")
        write(io, """<span class="cv-dates">$(dates)</span>\n""")
        write(io, """<span class="cv-title">$(title)</span>\n""")
        write(io, "</div>\n")
        if org != "" || location != ""
            meta = org
            if location != ""
                meta *= " — $location"
            end
            write(io, """<div class="cv-entry-meta">$(meta)</div>\n""")
        end
        if description != ""
            write(io, """<p class="cv-description">$(description)</p>\n""")
        end
        if !isempty(items)
            write(io, """<ul class="cv-items">\n""")
            for item in items
                write(io, "<li>$(item)</li>\n")
            end
            write(io, "</ul>\n")
        end
        write(io, "</div>\n")
    end
    return String(take!(io))
end

# ==============================================================================
# BibTeX Parsing for CV
# ==============================================================================

struct BibEntry
    key::String
    entrytype::String
    fields::Dict{String,String}
end

"""Simple BibTeX parser for the small CV bibliography file."""
function parse_bibtex(filepath::String)
    text = read(filepath, String)
    entries = BibEntry[]
    # Match each @type{key, ... } block
    for m in eachmatch(r"@(\w+)\{([^,]+),\s*(.*?)\n\}"s, text)
        entrytype = lowercase(m.captures[1])
        key = strip(m.captures[2])
        body = m.captures[3]
        fields = Dict{String,String}()
        # Match field = {value} or field = value
        for fm in eachmatch(r"(\w+)\s*=\s*\{((?:[^{}]|\{[^{}]*\})*)\}", body)
            fname = lowercase(strip(fm.captures[1]))
            fval = strip(fm.captures[2])
            fields[fname] = fval
        end
        # Also match field = value without braces (for month, year as bare words)
        for fm in eachmatch(r"(\w+)\s*=\s*([^{}\n,]+)", body)
            fname = lowercase(strip(fm.captures[1]))
            fval = strip(rstrip(fm.captures[2], ','))
            if !haskey(fields, fname)
                fields[fname] = fval
            end
        end
        # Clean up LaTeX escapes in all field values
        for (k, v) in fields
            fields[k] = latex_to_html(v)
        end
        push!(entries, BibEntry(key, entrytype, fields))
    end
    return entries
end

"""Filter bib entries by keyword value."""
function filter_by_keyword(entries::Vector{BibEntry}, kw::String)
    filter(entries) do e
        get(e.fields, "keywords", "") == kw
    end
end

"""Get year as integer for sorting."""
function bib_year(e::BibEntry)
    y = get(e.fields, "year", "0")
    parse(Int, y)
end

"""Month string to number for sorting."""
function bib_month(e::BibEntry)
    m = lowercase(get(e.fields, "month", ""))
    months = Dict("jan"=>1,"feb"=>2,"mar"=>3,"apr"=>4,"may"=>5,"jun"=>6,
                   "jul"=>7,"aug"=>8,"sep"=>9,"oct"=>10,"nov"=>11,"dec"=>12)
    # Handle numeric or 3-letter month
    if all(isdigit, m) && m != ""
        return parse(Int, m)
    end
    get(months, m[1:min(3,length(m))], 0)
end

"""Format author list from BibTeX 'Last, First AND ...' format."""
function format_authors(raw::String)
    # Handle "AND" separator (BibTeX style)
    parts = split(raw, r"\s+AND\s+")
    if length(parts) == 1
        # Try comma-and style: "Last, First and Last, First"
        parts = split(raw, r"\s+and\s+")
    end
    names = String[]
    for p in parts
        p = strip(p)
        if occursin(",", p)
            # "Last, First" -> "First Last"
            pieces = split(p, ","; limit=2)
            push!(names, strip(pieces[2]) * " " * strip(pieces[1]))
        else
            push!(names, p)
        end
    end
    return join(names, ", ")
end

"""Render journal publications as HTML."""
function hfun_cv_publications()
    entries = parse_bibtex("CV/SpencerLeeBibliography.bib")
    pubs = filter_by_keyword(entries, "journal")
    sort!(pubs, by=e -> (-bib_year(e), -bib_month(e)))
    io = IOBuffer()
    for e in pubs
        year = get(e.fields, "year", "")
        authors = format_authors(get(e.fields, "author", ""))
        title = get(e.fields, "title", "")
        journal = get(e.fields, "journal", "")
        volume = get(e.fields, "volume", "")
        pages = get(e.fields, "pages", "")
        url = get(e.fields, "url", "")
        doi = get(e.fields, "doi", "")

        write(io, """<div class="cv-bib-entry">\n""")
        write(io, """<span class="cv-dates">$(year)</span>\n""")
        write(io, """<span class="cv-bib-text">$(authors). <em>$(title)</em>. $(journal)""")
        if volume != ""
            write(io, ", $(volume)")
        end
        if pages != ""
            write(io, ", $(pages)")
        end
        write(io, ".")
        if url != ""
            write(io, """ <a href="$(url)">[link]</a>""")
        end
        write(io, "</span>\n</div>\n")
    end
    return String(take!(io))
end

"""Render tech reports as HTML."""
function hfun_cv_techreports()
    entries = parse_bibtex("CV/SpencerLeeBibliography.bib")
    reports = filter_by_keyword(entries, "techreport")
    sort!(reports, by=e -> (-bib_year(e), -bib_month(e)))
    io = IOBuffer()
    for e in reports
        year = get(e.fields, "year", "")
        title = get(e.fields, "title", "")
        authors = haskey(e.fields, "author") ? format_authors(e.fields["author"]) : ""
        institution = get(e.fields, "institution", "")
        etype = get(e.fields, "type", "")
        url = get(e.fields, "url", "")

        write(io, """<div class="cv-bib-entry">\n""")
        write(io, """<span class="cv-dates">$(year)</span>\n""")
        write(io, """<span class="cv-bib-text">""")
        if authors != ""
            write(io, "$(authors). ")
        end
        write(io, "<em>$(title)</em>. $(institution)")
        if etype != ""
            write(io, ". $(etype)")
        end
        write(io, ".")
        if url != ""
            write(io, """ <a href="$(url)">[link]</a>""")
        end
        write(io, "</span>\n</div>\n")
    end
    return String(take!(io))
end

"""Render talks as HTML."""
function hfun_cv_talks()
    entries = parse_bibtex("CV/SpencerLeeBibliography.bib")
    talks = filter_by_keyword(entries, "talk")
    sort!(talks, by=e -> (-bib_year(e), -bib_month(e)))
    io = IOBuffer()
    for e in talks
        year = get(e.fields, "year", "")
        title = get(e.fields, "title", "")
        venue = get(e.fields, "howpublished", "")
        address = get(e.fields, "address", "")

        write(io, """<div class="cv-bib-entry">\n""")
        write(io, """<span class="cv-dates">$(year)</span>\n""")
        write(io, """<span class="cv-bib-text"><em>$(title)</em>. $(venue)""")
        if address != ""
            write(io, ". $(address)")
        end
        write(io, ".</span>\n</div>\n")
    end
    return String(take!(io))
end

"""Render posters as HTML."""
function hfun_cv_posters()
    entries = parse_bibtex("CV/SpencerLeeBibliography.bib")
    posters = filter_by_keyword(entries, "poster")
    sort!(posters, by=e -> (-bib_year(e), -bib_month(e)))
    io = IOBuffer()
    for e in posters
        year = get(e.fields, "year", "")
        title = get(e.fields, "title", "")
        venue = get(e.fields, "howpublished", "")
        address = get(e.fields, "address", "")

        write(io, """<div class="cv-bib-entry">\n""")
        write(io, """<span class="cv-dates">$(year)</span>\n""")
        write(io, """<span class="cv-bib-text"><em>$(title)</em>. $(venue)""")
        if address != ""
            write(io, ". $(address)")
        end
        write(io, ".</span>\n</div>\n")
    end
    return String(take!(io))
end

# ==============================================================================
# Original Franklin helper functions
# ==============================================================================

function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

"""
Modified from https://discourse.julialang.org/t/franklin-jl-list-of-pages/74758/5
Call using {{blogposts}}
"""
@delay function hfun_blogposts()
    today = Dates.today()
    curyear = year(today)
    curmonth = month(today)
    curday = day(today)

    list = readdir("BlogPosts")

    filter!(endswith(".md"), list)
    function sorter(p)
        ps = splitext(p)[1]
        url = "BlogPosts/$ps/"
        surl = strip(url, '/')
        pubdate = pagevar(surl, "date")
    end
    sort!(list, by=sorter, rev=true)

    io = IOBuffer()
    write(io, """<ul class="blog-posts">""")
    for (i, post) in enumerate(list)
        if post == "index.md"
            continue
        end
        ps = splitext(post)[1]
        url = "/BlogPosts/$ps/"
        surl = strip(url, '/')
        title = pagevar(surl, "title")
        pubdate = pagevar(surl, "date")
        if isnothing(pubdate)
            pubdate = "$curyear-$curmonth-$curday"
        end
        write(io, "<li>")
        write(io, """<span class="blog-date">[$pubdate]</span> <a href="$url">$title</a>""")
        write(io, "</li>")
    end
    write(io, "</ul>")
    return String(take!(io))
end

