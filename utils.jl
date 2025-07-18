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
    #write(io, """<ul class="blog-posts">""")

    write(io, """<div class="franklin-content">""")
    for (i, post) in enumerate(list)
        if post == "index.md"
            continue
        end
        ps = splitext(post)[1]
        write(io, "<li>")
        url = "BlogPosts/$ps/"
        url_aux = "./BlogPosts/$ps/"
        surl = strip(url, '/')
        title = pagevar(surl, "title")
        pubdate = pagevar(surl, "date")
        if isnothing(pubdate)
            date = "$curyear-$curmonth-$curday"
        end
        write(io, """$pubdate: """)
        write(io, """<a href="$url_aux">$title</a></b><p>""")
    end
    write(io, "</div>")
    return String(take!(io))
end

