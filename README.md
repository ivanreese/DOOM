# DOOM

DOOM is a high-ish performance DOM manipulation tool with a declarative API intended for use in procedural or functional code. Use it as a first level above the raw DOM, below your bespoke custom HTML component framework or game engine SVG renderer.

It's named DOOM so that you get to have the word "DOOM" in your code.

To make good use of DOOM, you already need to be fairly familiar with how the DOM works. This library doesn't introduce any abstractions, it just offers some caching and a more concise syntax optimized for CoffeeScript.

### Basic Usage

DOOM attaches itself to the window, to the current `this` wherever it's loaded (typically also the window), and it integrates with [Take & Make](https://github.com/cdig/take-and-make) if they exist.

#### Writing

Call the `DOOM` function with an element, and an object where keys are the name of a property, attribute, or style and the values are the desired value.

```coffee
DOOM elm,
  innerHTML: "<h1>ERROR</h1>" # property
  myCustomAttr: "active" # attribute
  color: "red" # style
```

Values you supply are cached, and repeated writes with the same value are ignored. This is very helpful if you prefer working in an immediate-mode style, as there's normally a fairly high cost to touching the DOM even if nothing will change as a result. This is especially true of SVG.

Speaking of SVG, DOOM is designed to account for the differences between the HTML DOM and the SVG DOM. If you set a value like `"fontSize"`, it'll be set as an inline style in HTML and as an attribute in SVG.

How does DOOM determine whether to set something as a property, an attribute, or a style? See the source code — there are lists of attributes, properties, and styles. If DOOM doesn't recognize a name you supply it will be used as an attribute, since custom attributes are extremely common.

#### Reading

Call `DOOM` with an element and the name of a DOM property, HTML attribute, or inline style.

```coffee
console.log DOOM elm, "value" # property
console.log DOOM elm, "disabled" # attribute
console.log DOOM elm, "display" # style
```

DOOM will return whatever value DOOM has in its cache — or (as a fallback) whatever value the browser has. The fact that the cache wins automatically if it has a value is important to keep in mind. DOOM doesn't do anything to detect if the ground truth has changed, to avoid throwing you off a performance cliff. If you need the ground truth, use whichever real DOM method is most appropriate for the situation.

### Element Manipulation

DOOM also offers a handful of functions for manipulation the DOM hierarchy.

You can create a new DOM element by calling `DOOM.create` with the tag name, (optional) parent element, and (optional) object of props/attrs/styles to set on the new element.

```coffee
div = DOOM.create "div", document.body, textContent: "I feel elemental."
```

There's also the old standbys from the JQuery era...

```coffee
DOOM.append someParentElm, adoptedChild # Adds a child to the bottom
DOOM.prepend someParentElm, precociousChild # Adds a child to the top
DOOM.remove someParentElm, offToCollege # Removes a child
DOOM.empty someParentElm # Removes all children
```

### Special Rules for Keys

* For HTML attributes, `lowerCamelCase` is normalized into `kebab-case`.
* An exception to the above is the list of `attrNames` in the code — these are treated as case-sensitive and are not normalized. This is essential for SVG, which uses a handful of case-sensitive attribute names.
* If you need to use a name that isn't a legal key literal, supply it as a string key: `DOOM elm, "-webkit-filter": "blur(12px)"`

### Special Rules for Values

* When setting an HTML attribute, use an empty string to set a boolean attribute: `DOOM elm, disabled: ""`
* If you want to remove an attribute, pass null: `DOOM elm, disabled: null`.
* `undefined` values are ignored.

### Project Philosophy

DOOM is not in npm. When I use it, I just copy-paste the source code into each project. It's so small, it feels like overkill to commit to any particular ecosystem (beyond CoffeeScript — though it'd be easy enough to just use [js2.coffee](http://js2.coffee) to precompile it if you aren't a CoffeeScript drinker). After copying DOOM into your codebase, you should modify the attr, prop, and style lists as needed to suit what you're doing. That's why those lists aren't exhaustive — I don't want to waste bytes on stuff I'm not using. DOOM is basically "done" and I can't foresee making any changes to it, so there's little risk of missing out on upstream changes.

DOOM has been used on [LunchBox Sessions](https://www.lunchboxsessions.com) for several years now, and thus has been run tens or maybe hundreds of millions of times in tons of permutations without any known issues. So if you do manage to find the bugs, that'd be awesome, because I'm having some trouble turning them up.

### That's it?

That's DOOM! This is me on Twitter: [https://twitter.com/spiralganglion](https://twitter.com/spiralganglion). Enjoy.
