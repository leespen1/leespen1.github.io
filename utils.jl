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
        write(io, """$pubdate: """)
        write(io, """<a href="$url">$title</a></b><p>""")
        write(io, "</li>")
    end
    write(io, "</ul>")
    return String(take!(io))
end

