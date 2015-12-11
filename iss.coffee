class tea
  constructor : (input, password) ->
    #The text to be processed
    @text = String(input)
    ##This will allow us to process the input text as unicode
    @textUTF8 = decodeURIComponent(escape(@text))
    #Makes text available as a 64 bit long 
    @textATOB = atob(@text).toLong()
    
    
    #The encryption key
    @pass = String(password)
    #This will use to process the password in unicode
    @passUTF8 = decodeURIComponent(escape(@pass))
    
    @delta = 0x9E3779B9
    
  encrypt : ->
    
    
    @textUTF8 = @textUTF8.toLong()
    k = @passUTF8.slice(0, 16).toLong()
    if @textUTF8.length < 2
       @textUTF8[1] = 0
    n = @textUTF8.length
    z = @textUTF8[n - 1]
    y = @textUTF8[0]
    mx = undefined
    e = undefined
    q = Math.floor(6 + 52 / n)
    sum = 0
    while q-- > 0
      sum += @delta
      e = sum >>> 2 & 3
      p = 0
      while p < n
        y = @textUTF8[(p + 1) % n]
        mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ ((sum ^ y) + (k[p & 3 ^ e] ^ z))
        z = @textUTF8[p] += mx
        p++
    btoa(@textUTF8.makeString())


  decrypt : ->
    
    
    k = unescape(encodeURIComponent(@pass)).slice(0, 16).toLong()
    n = @textATOB.length
    z = @textATOB[n - 1]
    y = @textATOB[0]
    mx = undefined
    e = undefined
    q = Math.floor(6 + 52 / n)
    sum = q * @delta
    while sum != 0
      e = sum >>> 2 & 3
      p = n - 1
      while p >= 0
        if p>0 
          zOp = p - 1
        else 
          zOp = n - 1
        z = @textATOB[zOp]
        mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ ((sum ^ y) + (k[p & 3 ^ e] ^ z))
        y = @textATOB[p] -= mx
        p--
      sum -= @delta
    unescape encodeURIComponent(@textATOB.makeString().replace(/\0+$/, ''))


Array::makeString = ->
  a = new Array(this.length)
  i = 0
  while i < this.length
    a[i] = String.fromCharCode(this[i] & 0xFF, this[i] >>> 8 & 0xFF, this[i] >>> 16 & 0xFF, this[i] >>> 24 & 0xFF)
    i++
  a.join ''
  
  
String::toLong = ->
  l = new Array(Math.ceil(this.length / 4))
  i = 0
  while i < l.length
    l[i] = this.charCodeAt(i * 4) + 
    (this.charCodeAt(i * 4 + 1) << 8) + 
    (this.charCodeAt(i * 4 + 2) << 16) + 
    (this.charCodeAt(i * 4 + 3) << 24)
    i++
  l
  

entries = new (Mongo.Collection)('entries')
if Meteor.isClient
  Template.crypt.onRendered ->
    $('#infoModal').modal 'show'
  Template.crypt.events
    'keyup #UserName': (event, template) ->
      thisVar = template.find('#UserName').value
      Session.set 'entry', thisVar
    'keypress #NewEntry': (event, template) ->
      
      if '' == thisUser
        return $.bootstrapGrowl('Please entry a name', type: 'danger')
      else
        if event.charCode == 13 || event.keyCode == 13
          $("#NewEntry").blur();
          thisUser = template.find('#UserName').value
          thisEntry = unescape( encodeURIComponent(template.find('#NewEntry').value))
          thisKey = unescape( encodeURIComponent(template.find('#UserKey').value))
          encryptor = new tea(thisEntry, thisKey)
          cipherText = encryptor.encrypt()
          entries.insert
            name: thisUser
            value: cipherText
          return $.bootstrapGrowl('Entry Saved!')
      return
    'click .valueTD':(event, template) ->
      thisKey = $("#UserKey").val()
      decryptor = new tea(event.target.textContent, thisKey)
      event.target.textContent = decryptor.decrypt()
      return
    'click #resetData': ->
      location.reload()
  Template.crypt.helpers getEntry: ->
    entries.find name: $regex: Session.get('entry')

