class Line

  constructor: (gradient, intercept) ->
    @gradient = gradient
    @intercept = intercept


class KindaiCropper 

  constructor: (image) ->
    @canvas = document.createElement('canvas')
    @canvas.width = image.width
    @canvas.height = image.height
    @ctx = @canvas.getContext('2d')
    @width = @canvas.width
    @height = @canvas.height
    @ctx.drawImage(image, 0, 0)
    @grayscale()
    @

  grayscale: ->
    data = @ctx.getImageData(0, 0, @width, @height).data
    @gray = []
    for d, i in data by 4
      r = data[i]
      g = data[i+1]
      b = data[i+2]      
      @gray[i/4]= Math.ceil(0.2126*r + 0.7152*g + 0.0722*b)

  getPixel: (x, y) ->
    @gray[y*@width+x]

  verticalLine: (x) ->    
    (@getPixel(x, y) for y in [0..@height-1])

  horizontalLine: (y) ->    
    (@getPixel(x, y) for x in [0..@width-1])

  findEdge: (line, threshold, reverse=false) ->
    line = line.reverse() if reverse    
    # 閾値検出
    for d, i in line
      continue if i < line.length*0.03 or i > line.length*0.97
      if Math.abs(line[i+5]-line[i]) > threshold
        return if reverse then (line.length-i-1) else i
    null

  crop: ->
    edges = @sampleEdgePoints()
    for d in ["top","left","right", "bottom"]
      if d in ["top", "bottom"]
        edges[d] = @removeOutliersY(edges[d])
      if d in ["left", "right"]
        edges[d] = @removeOutliersX(edges[d])
      edges[d] = @orthogonalRegression(edges[d])
    # 左上
    lt = @intersection(edges["top"], edges["left"])
    # 右上
    rt = @intersection(edges["bottom"], edges["right"])
    width = rt[0] - lt[0]
    height = rt[1] - lt[1]
    # x, y, w, h
    left: [lt[0], lt[1], Math.ceil(width/2), height]
    right: [Math.ceil((lt[0]+rt[0])/2), lt[1], Math.ceil(width/2), height]

  intersection: (line1, line2) ->
    a= line1.gradient
    b= line1.intercept
    c= line2.gradient
    d= line2.intercept
    x=  (b-d)/(c-a)
    y=  a*x+b
    [Math.ceil(x), Math.ceil(y)]

  sampleEdgePoints: (threshold=8, span=5, margin = 5) ->
    vLines = (@verticalLine(x) for x in [0..@width-1] by span)
    hLines = (@horizontalLine(y) for y in [0..@height-1] by span)
    top = (@findEdge(line, threshold) for line in vLines)
    bottom = (@findEdge(line, threshold, true) for line in vLines)
    left = (@findEdge(line, threshold) for line in hLines)
    right = (@findEdge(line, threshold, true) for line in hLines)
    top: ([i*span, y] for y, i in top when y and y < @height*0.3)
    bottom: ([i*span, y] for y, i in bottom when y  and y > @height*0.7)
    left: ([x, i*span] for x, i in left when x and x < @width*0.3)
    right: ([x, i*span] for x, i in right when x and x > @width*0.7)

  removeOutliersX: (samples) ->
    samples = (s for s in samples when s[0]? and s[1]?)
    n = samples.length
    xSeq = (sample[0] for sample in samples)
    meanX = (xSeq.reduce (a,b) -> a+b)/n
    variance = ((xi-meanX)*(xi-meanX)/n for xi in xSeq).reduce (a,b)-> a+b
    deviation = Math.sqrt(variance)
    result = []
    for s in samples
      unless s[0] < meanX-2*deviation or s[0] > meanX+2*deviation 
        result.push s
    result

  removeOutliersY: (samples) ->
    samples = (s for s in samples when s[0]? and s[1]?)
    n = samples.length
    ySeq = (sample[1] for sample in samples)
    meanY = (ySeq.reduce (a,b) -> a+b)/n
    variance = ((yi-meanY)*(yi-meanY)/n for yi in ySeq).reduce (a,b)-> a+b
    deviation = Math.sqrt(variance)
    result = []
    for s in samples
      unless s[1] < meanY-2*deviation or s[1] > meanY+2*deviation 
        result.push s
    result    

  orthogonalRegression: (samples) ->
    samples = (s for s in samples when s[0]? and s[1]?)
    n = samples.length
    xSeq = (sample[0] for sample in samples)
    ySeq = (sample[1] for sample in samples)
    meanX = (xSeq.reduce (a,b) -> a+b)/n
    meanY = (ySeq.reduce (a,b) -> a+b)/n
    sxx = ((xi-meanX)*(xi-meanX)/n for xi in xSeq).reduce (a,b)-> a+b
    syy = ((yi-meanY)*(yi-meanY)/n for yi in ySeq).reduce (a,b)-> a+b
    sxy = ((xy[0]-meanX)*(xy[1]-meanY)/n for xy in samples).reduce (a,b)-> a+b
    dscr = (sxx-syy)*(sxx-syy) + 4*sxy*sxy
    if sxy isnt 0
      gradient = (syy-sxx+Math.sqrt(dscr))/(2*sxy)
      result = 
        gradient: gradient
        intercept: meanY - gradient*meanX
    else
      if sxx > syy
        result = 
          gradient: 0
          intercept: meanY
      else
        result =
          gradient: Infinity
          intercept: 0
    result
    
window.KindaiCropper = KindaiCropper
  

  

