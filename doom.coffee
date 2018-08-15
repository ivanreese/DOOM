do ()->

  svgNS = "http://www.w3.org/2000/svg"
  xlinkNS = "http://www.w3.org/1999/xlink"

  # This is used to cache normalized keys, and to provide defaults for keys that shouldn't be normalized
  attrNames =
    gradientUnits: "gradientUnits"
    preserveAspectRatio: "preserveAspectRatio"
    startOffset: "startOffset"
    viewBox: "viewBox"
    # common case-sensitive attr names should be listed here as needed — see svg.cofee for reference

  propNames =
    childNodes: true
    firstChild: true
    innerHTML: true
    lastChild: true
    nextSibling: true
    parentElement: true
    parentNode: true
    previousSibling: true
    textContent: true
    value: true

  styleNames =
    animation: true
    animationDelay: true
    background: true
    borderRadius: true
    color: true
    display: true
    fontSize: "html" # Only treat as a style if this is an HTML elm
    fontFamily: true
    fontWeight: true
    height: "html"
    letterSpacing: true
    lineHeight: true
    maxHeight: true
    maxWidth: true
    margin: true
    marginTop: true
    marginLeft: true
    marginRight: true
    marginBottom: true
    minWidth: true
    minHeight: true
    opacity: "html"
    overflow: true
    overflowX: true
    overflowY: true
    padding: true
    paddingTop: true
    paddingLeft: true
    paddingRight: true
    paddingBottom: true
    pointerEvents: true
    textDecoration: true
    transform: "html"
    transition: true
    visibility: true
    width: "html"
    zIndex: true

  svgElms =
    circle: true
    clipPath: true
    defs: true
    g: true
    image: true
    mask: true
    path: true
    rect: true
    svg: true
    text: true
    use: true


  read = (elm, k)->
    if propNames[k]?
      elm._HTML_prop[k] ?= elm[k]
    else if styleNames[k]?
      elm._HTML_style[k] ?= elm.style[k]
    else
      k = attrNames[k] ?= k.replace(/([A-Z])/g,"-$1").toLowerCase() # Normalize camelCase into kebab-case
      elm._HTML_attr[k] ?= elm.getAttribute k


  write = (elm, k, v)->
    if propNames[k]?
      cache = elm._HTML_prop
      isCached = cache[k] is v
      elm[k] = cache[k] = v if not isCached
    else if styleNames[k]? and !(elm._DOOM_SVG and styleNames[k] is "html")
      cache = elm._HTML_style
      isCached = cache[k] is v
      elm.style[k] = cache[k] = v if not isCached
    else
      cache = elm._HTML_attr
      return if cache[k] is v
      cache[k] = v
      ns = if k is "xlink:href" then xlinkNS else null # Grab the namespace if needed
      k = attrNames[k] ?= k.replace(/([A-Z])/g,"-$1").toLowerCase() # Normalize camelCase into kebab-case
      if ns?
        if v? # check for null
          elm.setAttributeNS ns, k, v # set DOM attribute
        else # v is explicitly set to null (not undefined)
          elm.removeAttributeNS ns, k # remove DOM attribute
      else
        if v? # check for null
          elm.setAttribute k, v # set DOM attribute
        else # v is explicitly set to null (not undefined)
          elm.removeAttribute k # remove DOM attribute


  act = (elm, opts)->
    # Initialize the caches
    elm._HTML_attr ?= {}
    elm._HTML_prop ?= {}
    elm._HTML_style ?= {}

    if typeof opts is "object"
      for k, v of opts
        write elm, k, v
        null
      return elm
    else if typeof opts is "string"
      return read elm, opts


  # PUBLIC API ####################################################################################

  # The first arg can be an elm or array of elms
  # The second arg can be an object of stuff to update in the elm(s), in which case we'll return the elm(s).
  # Or it can be a string prop/attr/style to read from the elm(s), in which case we return the value(s).
  @DOOM = (elms, opts)->
    elms = [elms] unless typeof elms is "array"
    throw new Error "DOOM was called with a null element" unless elm? for elm in elms
    throw new Error "DOOM was called with null options" unless opts?
    results = (act elm, opts for elm in elms)
    return if results.length is 1 then results[0] else results


  DOOM.create = (type, parent, query)->
    if svgElms[type]?
      elm = document.createElementNS svgNS, type
      if type is "svg"
        (query ?= {}).xmlns = svgNS
      else
        elm._DOOM_SVG = true
    else
      elm = document.createElement type
    DOOM elm, query if query?
    DOOM.append parent, elm if parent?
    return elm


  DOOM.append = (parent, child)->
    parent.appendChild child
    return child


  DOOM.prepend = (parent, child)->
    if parent.hasChildNodes()
      parent.insertBefore child, parent.firstChild
    else
      parent.appendChild child
    return child


  DOOM.remove = (parent, child)->
    parent.removeChild child if child.parentNode is parent
    return child


  DOOM.empty = (elm)->
    elm.innerHTML = ""


  # Integrate with Take&Make if possible
  LBSMake "DOOM", DOOM if LBSMake?
