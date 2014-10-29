/**
 *  @package	Flickrshow
 *  @subpackage	Javascript
 *  @author		Ben Sekulowicz-Barclay
 *  @version    7.1
 *
 *  Flickrshow is a Beseku thing licensed under a Creative Commons Attribution 3.0 
 *  Unported License. For more information visit http://www.flickrshow.com.
 */

var flickrshow = function (target, settings) {
    
    /**
     *  Ensure that the user has executed the function using the 'new' keyword ...
     */
     
    if (!(this instanceof flickrshow)) return new flickrshow(target, settings);
          
    /**
     *  Secure the 'this' variable scope within the function by assigning it
     *  to the _ character. We shouldn't need to use 'this' again from here ...
     */

    var _ = this;

    /**
     *  Standard event management library, shamelessly lifted from Jon Resich and
     *  Peter Paul Koch.
     *
     *  http://www.quirksmode.org/blog/archives/2005/10/_and_the_winner_1.html#more
     *
     *  @access	private
     *  @param  string
     *  @param  object
     *  @return	object
     */

    _.addEvent = function  (obj, type, fn) {
        if (obj.addEventListener) {
            obj.addEventListener( type, fn, false );
        } else if (obj.attachEvent) {
            obj['e' + type + fn] = fn;
            obj[type + fn] = function() { 
                obj['e' + type + fn]( window.event ); 
            };
            obj.attachEvent('on' + type, obj[type + fn]);
        }
    };

    /**
     *  @access	private
     *  @return	string
     */

    _.addUrl = function() {
        var pms = {
            'api_key': '6cb7449543a9595800bc0c365223a4e8',
            'extras': 'url_s,url_m,url_z,url_l',
            'format': 'json',
            'jsoncallback': 'flickrshow_jsonp_' + _.constants.random,
            'page': _.settings.page,
            'per_page': _.settings.per_page
        };
        
        // If the license has been changed from the default ...
        if (_.settings.license) pms.license = _.settings.license;

        // If we are fetching a group's images
        if (_.settings.gallery) {
            pms.method = 'flickr.galleries.getPhotos';
            pms.gallery_id = _.settings.gallery;

        } else if (_.settings.group) {
            pms.method = 'flickr.groups.pools.getPhotos';
            pms.group_id = _.settings.group;

        // If we are fetching a photoset's images
        } else if (_.settings.set) {
            pms.method = 'flickr.photosets.getPhotos';
            pms.photoset_id = _.settings.set;

        // If we are fetching images of a person
        } else if (_.settings.person) {
            pms.method = 'flickr.people.getPhotosOf';
            pms.user_id = _.settings.person;

        // If we are fetching images via a tag search or user search or both
        } else if (_.settings.tags || _.settings.user) {
            pms.method = 'flickr.photos.search';

            if (_.settings.tags) pms.tags = _.settings.tags;
            if (_.settings.user) pms.user_id = _.settings.user;
        
        // If we get this far, we are just displaying recent images ...    
        } else {
            pms.method = 'flickr.photos.getRecent';
        }

        var url = 'https://api.flickr.com/services/rest/?';

        // Loop through the parameters and append them to the URL ...
        for (var i in pms) url += i + '=' + pms[i] + '&';

        return url;
    };

    /**
     *	@access	private
     *	@param  object
     *	@param  string
     *	@param  string
     *	@param  integer
     *	@param  string
     *	@return	void
     */

    _.animate = function(element, property, endValue, speed, identifier) {
        // If we already have an animation in this slot, stop it now
        if ('undefined' !== typeof _.constants.intervals[identifier]) window.clearInterval(_.constants.intervals[identifier]);
        
        // Define our interval function
        _.constants.intervals[identifier] = window.setInterval(function() {
            var currentValue = Math.round(element.style[property].replace(/([a-zA-Z]{2})$/, ''));
            var newValue = Math.round(endValue - currentValue);
            
            // If there is still animation to be had ...
            if ((Math.abs(newValue)) > 1) {
                element.style[property] = Math.floor(currentValue + (newValue / 2)) + 'px';
            
            // If there is no more animation to be had ...
            } else {
                element.style[property] = endValue + 'px';
                window.clearInterval(_.constants.intervals[identifier]);
            }
        }, speed/1.5);
    };

    /**
     *	@access	private
     *	@return	void
     */

    _.onClickLeft = function() {
        // If we don't need to animate ...
        if (_.constants.isLoading === true) return;
        
        // Decide which way to go ...
        _.constants.imageCurrent = ((_.constants.imageCurrent - 1) < 0)? _.constants.imageTotal - 1: _.constants.imageCurrent - 1;
        
        // Animate the element and update the details ...
        _.animate(_.elements.images, 'left', '-' + (_.constants.imageCurrent * _.elements.target.offsetWidth), _.constants.speed, 'i');
        _.showTitle();
        
        // If there is a user supplied callback for moving, run it now ...
        if (typeof _.settings.onMove == 'function') _.settings.onMove(_.elements.images.childNodes[_.constants.imageCurrent].childNodes[0]);
    };

    /**
     *	@access	private
     *	@return	void
     */

    _.onClickPlay = function() {
        if (_.constants.isPlaying === false) {
            _.constants.isPlaying = true;
            _.elements.buttons.childNodes[2].style.backgroundImage = 'url(' + _.constants.base_url + 'static/images/is.png)';
            
            // Create our play interval
            _.constants.intervals['playing'] = window.setInterval(function() {
                _.onClickRight();
            }, _.settings.interval);
            
            // If there is a user supplied callback for moving, run it now ...
            if (typeof _.settings.onPlay == 'function') _.settings.onPlay();
        
        } else {
            _.constants.isPlaying = false;
            _.elements.buttons.childNodes[2].style.backgroundImage = 'url(' + _.constants.base_url + 'static/images/ip.png)';
            
            window.clearInterval(_.constants.intervals['playing']);
            
            // If there is a user supplied callback for pausing, run it now ...
            if (typeof _.settings.onPause == 'function') _.settings.onPause(_.elements.images.childNodes[_.constants.imageCurrent].childNodes[0]);
        }
    };

    /**
     *	@access	private
     *	@return	void
     */

    _.onClickRight = function() {
        // If we don't need to animate ...
        if (_.constants.isLoading === true) return;
        
        // Decide which way to go ...
        _.constants.imageCurrent = ((_.constants.imageCurrent + 2) > _.constants.imageTotal)? 0: _.constants.imageCurrent + 1;
        
        // Animate the element and update the details ...
        _.animate(_.elements.images, 'left', '-' + (_.constants.imageCurrent * _.elements.target.offsetWidth), _.constants.speed, 'i');
        _.showTitle();
        
        // If there is a user supplied callback for moving, run it now ...window.clearInterval
        if (typeof _.settings.onMove == 'function') _.settings.onMove(_.elements.images.childNodes[_.constants.imageCurrent].childNodes[0]);
    };

    /**
     *  @access	private
     *  @param  object
     *  @return boolean
     */

    _.onLoadImage = function(event) {
        // Grab the image from the event data ...
        var img = (event.srcElement || event.target);
        
        // Setup our dimension vars ...
        var ch = img.offsetHeight, 
            cw = img.offsetWidth,             
            nh = 0,
            nw = 0;
        
        // Depending on the ratio of the image, resize it ...
        if (cw > ch) {
            nw = Math.ceil(_.elements.target.offsetWidth + (_.elements.target.offsetHeight / 100));
            nh = Math.ceil((nw/cw) * ch);
        } else {
            nh = Math.ceil(_.elements.target.offsetHeight + (_.elements.target.offsetHeight / 100));
            nw = Math.ceil((nh/ch) * cw);
        }
        
        // Update the styles on our image if we can ...
        try {
            img.style.height = nh + 'px';
            img.style.left = Math.round((_.elements.target.offsetWidth - nw) / 2) + 'px';
            img.style.position = 'absolute';
            img.style.top = Math.round((_.elements.target.offsetHeight - nh) / 2) + 'px';
            img.style.width = nw + 'px';
        } catch(e) {
            // @TODO - Throw an error ...?
        }
        
        // Update the loading state ...
        _.constants.imageLoaded ++;
        
        // Calculate the loading state and update the loading bar ...
        var percentLoaded = Math.round((_.constants.imageLoaded / _.constants.imageTotal) * 240);
        _.animate(_.elements.loading.childNodes[0], 'width', ((percentLoaded <= 36)? 36: percentLoaded), 'loading');
        
        // If we have loaded all of the images ...
        if (_.constants.imageLoaded === _.constants.imageTotal) {
            // Update the current image details ...
            _.showTitle();
            
            // Remove any loading states/classes
            _.elements.container.removeChild(_.elements.loading);
            _.elements.images.style.visibility = 'visible';
            _.constants.isLoading = false;
            
            // If we are autoplaying, do it now ...
            if (_.settings.autoplay === true) _.onClickPlay();
            
            // If there is a user supplied callback for loading, run it now ...
            if (typeof _.settings.onLoad == 'function') _.settings.onLoad();
        };
    };

    /**
     *  @access	private
     *  @param  object
     *  @return boolean
     */

    _.onLoadJson = function(event) {
        // Remove the script call ... and global callback function
        _.elements.script.parentNode.removeChild(_.elements.script);
        
        // @HACK - If we are fetching photosets, move the variables around a bit ...
        if (event.photoset) {
            for (var j in event.photoset.photo) event.photoset.photo[j].owner = event.photoset.owner;
            event.photos = event.photoset;
        }
        
        // If there is an error in the data ...
        if (event.stat && event.stat == 'fail' || (!event.photos)) {
            throw 'Flickrshow: ' + (event.message || 'There was an unknown error with the data returned by Flickr');
        }
        
        // Define our total images
        _.constants.imageTotal = event.photos.photo.length;
        
        // Add the images/date to the list ...
        for (var i in event.photos.photo) {
            // Create our IMG HTML fragment ...
            var img = document.createElement('img');
            img.setAttribute('data-flickr-title', event.photos.photo[i].title);
            img.setAttribute('data-flickr-photo_id', event.photos.photo[i].id);
            img.setAttribute('data-flickr-owner', event.photos.photo[i].owner);
            img.setAttribute('rel', i);
            img.style.cursor = 'pointer';
            img.style.display = 'block';
            img.style.margin = '0';
            img.style.padding = '0';
            
            // Create our test areas ...
            var areaT = _.elements.target.offsetHeight * _.elements.target.offsetWidth,
                areaZ = event.photos.photo[i].height_z * event.photos.photo[i].width_z,
                areaM = event.photos.photo[i].height_m * event.photos.photo[i].width_m,
                areaS = event.photos.photo[i].height_s * event.photos.photo[i].width_s;
            
            // Ensure we have all the image URLs ...
            if (!event.photos.photo[i].url_m) event.photos.photo[i].url_m = event.photos.photo[i].url_s;
            if (!event.photos.photo[i].url_z) event.photos.photo[i].url_z = event.photos.photo[i].url_m;
            if (!event.photos.photo[i].url_l) event.photos.photo[i].url_l = event.photos.photo[i].url_z;
            
            // Update the image source based on the slideshow size ...
            if (areaT > areaZ) {
                img.src = event.photos.photo[i].url_l + '?' + _.constants.random;
            } else if (areaT > areaM) {
                img.src = event.photos.photo[i].url_z + '?' + _.constants.random;
            } else if (areaT > areaS) {
                img.src = event.photos.photo[i].url_m + '?' + _.constants.random;
            } else {
                img.src = event.photos.photo[i].url_s + '?' + _.constants.random;
            }
            
            // Create our list node object
            var li = document.createElement('li');
            li.style.left = (i * _.elements.target.offsetWidth) + 'px';
            li.style.height = _.elements.target.offsetHeight + 'px';
            li.style.margin = '0';
            li.style.overflow = 'hidden';
            li.style.padding = '0';
            li.style.position = 'absolute';
            li.style.top = '0';
            li.style.width = _.elements.target.offsetWidth + 'px';
            
            li.appendChild(img);
            _.elements.images.appendChild(li);
            
            // Create our onLoad event for the image ...
            _.addEvent(img, 'load', _.onLoadImage);
        }
    };
    
    /**
     *	@access	private
     *  @param  object
     *	@return	void
     */

    _.onLoadWindow = function(event)  {
         // Grab the target element (a string, (element ID) or a DOM element)
         _.elements.target = (typeof _.elements.target === 'string')? document.getElementById(_.elements.target): _.elements.target;

         
         // Add in the HTML elements we need
         _.elements.target.innerHTML = ('<div class="flickrshow-container" style="border:1px solid #467;background:transparent;height:' 
                                       + _.elements.target.offsetHeight 
                                       + 'px;margin:0;overflow:hidden;padding:0;position:relative;width:' 
                                       + _.elements.target.offsetWidth 
                                       + 'px"><div class="flickrshow-loading" style="background:transparent url(' 
                                       + _.constants.base_url 
                                       + 'static/images/bg.png);border-radius:12px;height:24px;left:50%;margin:-12px 0 0 -120px;overflow:hidden;padding:0;position:absolute;top:50%;width:240px;-moz-border-radius:12px;-webkit-border-radius:12px"><div class="flickrshow-loading-bar" style="background:#000;border-radius:12px;height:24px;left:0;margin:0;padding:0;position:absolute;top:0;width:0;-moz-border-radius:12px;-webkit-border-radius:12px"></div></div><ul class="flickrshow-images" style="background:transparent;height:' 
                                       + _.elements.target.offsetHeight 
                                       + 'px;left:0;list-style:none;margin:0;padding:0;position:absolute;top:0;visibility:hidden;width:' 
                                       + _.elements.target.offsetWidth 
                                       + 'px"></ul><div class="flickrshow-buttons" style="background:transparent url(' 
                                       + _.constants.base_url 
                                       + 'static/images/bg.png);height:40px;margin:0;padding:0;position:absolute;top:' 
                                       + _.elements.target.offsetHeight + 'px;width:' 
                                       + _.elements.target.offsetWidth + 'px"><div class="flickrshow-buttons-left" style="background:#000 url(' 
                                       + _.constants.base_url 
                                       + 'static/images/il.png) 50% 50% no-repeat;border-radius:12px;cursor:pointer;height:24px;left:auto;margin:0;padding:0;position:absolute;right:40px;top:8px;width:24px;-moz-border-radius:12px;-webkit-border-radius:12px"></div><div class="flickrshow-buttons-right" style="background:#000 url(' 
                                       + _.constants.base_url 
                                       + 'static/images/ir.png) 50% 50% no-repeat;border-radius:12px;cursor:pointer;height:24px;left:auto;margin:0;padding:0;position:absolute;right:8px;top:8px;width:24px;-moz-border-radius:12px;-webkit-border-radius:12px"></div><div class="flickrshow-buttons-play" style="background:#000 url(' 
                                       + _.constants.base_url 
                                       + 'static/images/ip.png) 50% 50% no-repeat;border-radius:12px;cursor:pointer;height:24px;left:8px;margin:0;padding:0;position:absolute;right:auto;top:8px;width:24px;-moz-border-radius:12px;-webkit-border-radius:12px"></div><p class="flickrshow-buttons-title" style="background:#000;border-radius:12px;color:#FFF;cursor:pointer;font:normal normal 600 11px/24px helvetica,arial,sans-serif;height:24px;left:40px;margin:0;overflow:hidden;padding:0 0;position:absolute;right:auto;text-align:center;text-shadow:none;text-transform:capitalize;top:8px;width:' 
                                       +  (_.elements.target.offsetWidth - 112)
                                       + 'px;-moz-border-radius:12px;-webkit-border-radius:12px">  </p></div></div>');
         
         // Get the elements we need from the above as DOM objects
         _.elements.container = _.elements.target.childNodes[0];
         _.elements.buttons = _.elements.target.childNodes[0].childNodes[2];
         _.elements.images = _.elements.target.childNodes[0].childNodes[1];
         _.elements.loading = _.elements.target.childNodes[0].childNodes[0];

         // If we are displaying the buttons bar, we need to add the events too
         if (false === _.settings.hide_buttons) {
             _.addEvent(_.elements.images, 'click', _.toggleButtons);
             _.addEvent(_.elements.container, 'mouseover', _.showButtons);
             _.addEvent(_.elements.container, 'mouseout', _.hideButtons);

             _.addEvent(_.elements.buttons.childNodes[0], 'click', _.onClickLeft);
             _.addEvent(_.elements.buttons.childNodes[1], 'click', _.onClickRight);
             _.addEvent(_.elements.buttons.childNodes[2], 'click', _.onClickPlay);

             _.addEvent(_.elements.buttons.childNodes[3], 'click', _.showFlickr);
         }

         // Generate a random callback function ...
         window['flickrshow_jsonp_' + _.constants.random] = _.onLoadJson;

         // ... And then add our script to load form Flickr ...
         _.elements.script = document.createElement('script');
         _.elements.script.async = true;
         _.elements.script.src = _.addUrl('flickrshow_jsonp_' + _.constants.random);
         (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(_.elements.script);
     };
    
    /**
     *	@access	private
     *	@return	void
     */

    _.hideButtons = function() {
        if ((_.constants.isLoading === true) || (_.constants.isButtonsOpen === false)) { return; }
        
        _.constants.isButtonsOpen = false;
        _.animate(_.elements.buttons, 'top', _.elements.target.offsetHeight, _.constants.speed, 'buttons');
    };

    /**
     *	@access	private
     *	@return	void
     */

    _.showButtons = function() {
        if ((_.constants.isLoading === true) || (_.constants.isButtonsOpen === true)) { return; }
        
        _.constants.isButtonsOpen = true;
        _.animate(_.elements.buttons, 'top', _.elements.target.offsetHeight - 40, _.constants.speed, 'buttons');
    };

    /**
     *	@access	private
     *	@return	void
     */

    _.toggleButtons = function() {
        (_.constants.isButtonsOpen === true)? _.hideButtons(): _.showButtons();
    };

    /**
     *	@access	private
     *	@return	void
     */

    _.showFlickr = function() {
        var img = _.elements.images.childNodes[_.constants.imageCurrent].childNodes[0];
        
        // If we can't get an image, stop here ...
        if ('undefined' === typeof img) return;
        
        // Redirect to the image's Flickr page ...
        window.location = 'http://www.flickr.com/photos/' + img.getAttribute('data-flickr-owner') + '/' + img.getAttribute('data-flickr-photo_id') + '/';
    };
    
    /**
     *	@access	private
     *	@return	void
     */

    _.showTitle = function() {
        var img = _.elements.images.childNodes[_.constants.imageCurrent].childNodes[0];
        
        // If we can't get an image, stop here ...
        if ('undefined' === typeof img) return;
        
        // Update the details
        _.elements.buttons.childNodes[3].innerHTML = (_.constants.imageCurrent + 1) + '/' + _.constants.imageTotal + ' - ' + img.getAttribute('data-flickr-title');
    };

    /**
     *  The objects containing our constants and settings, and the objects which
     *  will later directly reference DOM elements
     */

    _.constants = {
        base_url: 'http://www.flickrshow.com/',
        intervals:[],
        imageCurrent:0,
        imageLoaded:0,
        imageTotal:0,
        isButtonsOpen:false,
        isLoading:true,
        isPlaying:false,
        random: Math.floor(Math.random() * 999999999999),
        speed: 100
    };

    _.elements = {
        buttons: null,
        button1: null,
        button2: null,
        button3: null,
        button4: null,
        container: null,
        images: null,
        loading: null,
        script: null,
        target: null
    };

    _.settings = {
        autoplay: false,
        gallery: null,
        group: null,
        hide_buttons: false,
        interval: 3000,
        license: '1,2,3,4,5,6,7',
        onLoad: null,
        onMove: null,
        onPlay: null,
        onPause: null,
        page: '1',
        person: null,
        per_page: '50',
        set: null,
        tags: null,
        user: null
    };

    /**
     *  The user should have specified an element by ID or as a DOM object. Assign either
     *  to the instance variable. If it is an ID only, we shall fetch it later.
     */

     _.elements.target = target;

    /**
     *  Loop through our predefined allowed settings, above, and check through the
     *  user supplied list, overriding in any that have been provided by the user
     */

    for (var i in _.settings) {
        if ('undefined' !== typeof settings[i]) _.settings[i] = settings[i];
    };

    /**
     *  For backwards compatibility with Flickrshow 6.X, we should also test
     *  for the presence of the variables under their deprecated names and assign them
     *  in the same way.
     */

    if ('undefined' !== typeof settings.flickr_group) _.settings.group = settings.flickr_group;
    if ('undefined' !== typeof settings.flickr_photoset) _.settings.set = settings.flickr_photoset;
    if ('undefined' !== typeof settings.flickr_tags) _.settings.tags = settings.flickr_tags;
    if ('undefined' !== typeof settings.flickr_user) _.settings.user = settings.flickr_user;

    /**
     *  Once we get to this point all that is left is to wait until the DOM is ready
     *  to be manipulated, so we can start building our slideshow in the target element.
     */
     
    _.addEvent(window, 'load', _.onLoadWindow);

    /**
     *
     *
     */

    return {
        constants: _.constants,
        elements: _.elements,
        settings: _.settings,                
        left: _.onClickLeft,
        right: _.onClickRight,
        play: _.onClickPlay
    };
};

/**
 *
 *
 */
 
if (typeof window.jQuery != 'undefined') {
    window.jQuery.fn.flickrshow = function(settings) {
        return new flickrshow(window.jQuery(this)[0], settings);
    };
}
