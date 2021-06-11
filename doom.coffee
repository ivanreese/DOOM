do ()->

  svgNS = "http://www.w3.org/2000/svg"
  xlinkNS = "http://www.w3.org/1999/xlink"

  # This is used to cache normalized keys, and to provide defaults for keys that shouldn't be normalized
  attrNames =
    gradientUnits: "gradientUnits"
    preserveAspectRatio: "preserveAspectRatio"
    startOffset: "startOffset"
    viewBox: "viewBox"
    # common case-sensitive attr names should be listed here as needed — see svg.cofee in https://github.com/cdig/svg for reference

  eventNames =
    blur: true
    change: true
    click: true
    focus: true
    input: true
    keydown: true
    keypress: true
    keyup: true
    mousedown: true
    mouseenter: true
    mouseleave: true
    mousemove: true
    mouseup: true
    scroll: true

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
    fontSize: "html" # Only treat as a style if this is an HTML elm. SVG elms will treat this as an attribute.
    fontFamily: true
    fontWeight: true
    height: "html"
    left: true
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
    position: true
    textDecoration: true
    top: true
    transform: "html"
    transition: true
    visibility: true
    width: "html"
    zIndex: true

  # When creating an element, SVG elements require a special namespace, so we use this list to know whether a tag name is for an SVG or not
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
      elm._DOOM_prop[k] ?= elm[k]
    else if styleNames[k]?
      elm._DOOM_style[k] ?= elm.style[k]
    else
      k = attrNames[k] ?= k.replace(/([A-Z])/g,"-$1").toLowerCase() # Normalize camelCase into kebab-case
      elm._DOOM_attr[k] ?= elm.getAttribute k


  write = (elm, k, v)->
    if propNames[k]?
      cache = elm._DOOM_prop
      isCached = cache[k] is v
      elm[k] = cache[k] = v if not isCached
    else if styleNames[k]? and !(elm._DOOM_SVG and styleNames[k] is "html")
      cache = elm._DOOM_style
      isCached = cache[k] is v
      elm.style[k] = cache[k] = v if not isCached
    else if eventNames[k]?
      cache = elm._DOOM_event
      return if cache[k] is v
      if cache[k]?
        throw "DOOM experimentally imposes a limit of one handler per event per object."
        # If we want to add multiple handlers for the same event to an object,
        # we need to decide how that interacts with passing null to remove events.
        # Should null remove all events? Probably. How do we track that? Keep an array of refs to handlers?
        # That seems slow and error prone.
      cache[k] = v
      if v?
        elm.addEventListener k, v
      else
        elm.removeEventListener k, v
    else
      cache = elm._DOOM_attr
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
    elm._DOOM_attr ?= {}
    elm._DOOM_event ?= {}
    elm._DOOM_prop ?= {}
    elm._DOOM_style ?= {}

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
  DOOM = (elms, opts)->
    elms = [elms] unless typeof elms is "array"
    (throw new Error "DOOM was called with a null element" unless elm?) for elm in elms
    throw new Error "DOOM was called with null options" unless opts?
    results = (act elm, opts for elm in elms)
    return if results.length is 1 then results[0] else results


  DOOM.create = (type, parent, opts)->
    if svgElms[type]?
      elm = document.createElementNS svgNS, type
      if type is "svg"
        (opts ?= {}).xmlns = svgNS
      else
        elm._DOOM_SVG = true
    else
      elm = document.createElement type
    DOOM elm, opts if opts?
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


  DOOM.remove = (elm, child)->
    if child?
      elm.removeChild child if child.parentNode is elm
      return child
    else
      elm.remove()
      return elm


  DOOM.empty = (elm)->
    elm.innerHTML = ""


  # Attach to this
  @DOOM = DOOM if @?

  # Attach to the window
  window.DOOM = DOOM if window?

  # Integrate with Take & Make
  Make "DOOM", DOOM if Make?
