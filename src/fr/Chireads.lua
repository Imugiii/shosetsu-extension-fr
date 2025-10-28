-- {"id":10001,"ver":"1.0.0","libVer":"1.0.0","author":"Imugiii","repo":"https://github.com/Imugiii/shosetsu-extension-fr"}

--- Chireads - Web novels et Light Novels en français
local BASE_URL = "https://www.chireads.com"

local settings = {
    name = "Chireads",
    baseURL = BASE_URL,
    imageURL = "https://www.chireads.com/wp-content/uploads/2020/05/cropped-logo-chireads-192x192.png",
    id = 10001,
    lang = "fr",
    isSearchIncrementing = true,
    chapterType = ChapterType.HTML
}

local function shrinkURL(url, type)
    if not url then return "" end
    url = url:gsub("^https?://[^/]*chireads%.com", "")
    return url ~= "" and url or "/"
end

local function expandURL(url, type)
    return BASE_URL .. url
end

local function listings(data)
    local page = data[PAGE] or 1
    local url = BASE_URL
    if page > 1 then
        url = BASE_URL .. "/page/" .. page
    end
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select(".listupd article")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".bsx a")
        local titleElement = item:selectFirst(".tt")
        local imageElement = item:selectFirst("img")
        
        if linkElement and titleElement then
            local novel = Novel()
            novel:setTitle(titleElement:text())
            novel:setLink(shrinkURL(linkElement:attr("href"), KEY_NOVEL_URL))
            
            if imageElement then
                local imgUrl = imageElement:attr("src")
                if imgUrl == "" then
                    imgUrl = imageElement:attr("data-src")
                end
                novel:setImageURL(imgUrl)
            end
            
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function search(data)
    local page = data[PAGE] or 1
    local query = data[QUERY] or ""
    
    local url = BASE_URL .. "/page/" .. page .. "/?s=" .. query:gsub(" ", "+")
    
    local doc = GETDocument(url)
    local novels = {}
    
    local items = doc:select(".listupd article")
    
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local linkElement = item:selectFirst(".bsx a")
        local titleElement = item:selectFirst(".tt")
        local imageElement = item:selectFirst("img")
        
        if linkElement and titleElement then
            local novel = Novel()
            novel:setTitle(titleElement:text())
            novel:setLink(shrinkURL(linkElement:attr("href"), KEY_NOVEL_URL))
            
            if imageElement then
                local imgUrl = imageElement:attr("src")
                if imgUrl == "" then
                    imgUrl = imageElement:attr("data-src")
                end
                novel:setImageURL(imgUrl)
            end
            
            novels[#novels + 1] = novel
        end
    end
    
    return novels
end

local function parseNovel(novelURL, loadChapters)
    local url = expandURL(novelURL, KEY_NOVEL_URL)
    local doc = GETDocument(url)
    local novel = NovelInfo()
    
    local titleElement = doc:selectFirst(".entry-title")
    if titleElement then
        novel:setTitle(titleElement:text())
    end
    
    local imageElement = doc:selectFirst(".thumb img")
    if imageElement then
        local imgUrl = imageElement:attr("src")
        if imgUrl == "" then
            imgUrl = imageElement:attr("data-src")
        end
        novel:setImageURL(imgUrl)
    end
    
    local authorElement = doc:selectFirst(".author i")
    if authorElement then
        novel:setAuthors({ authorElement:text() })
    end
    
    local descElement = doc:selectFirst(".entry-content.entry-content-single")
    if descElement then
        novel:setDescription(descElement:text())
    end
    
    local genres = {}
    local genreElements = doc:select(".mgen a")
    for i = 0, genreElements:size() - 1 do
        genres[#genres + 1] = genreElements:get(i):text()
    end
    novel:setGenres(genres)
    
    if loadChapters then
        local chapters = {}
        local chapterElements = doc:select(".eplister ul li")
        
        for i = 0, chapterElements:size() - 1 do
            local element = chapterElements:get(i)
            local linkElement = element:selectFirst("a")
            local titleElement = element:selectFirst(".chapternum")
            
            if linkElement and titleElement then
                local chapter = NovelChapter()
                chapter:setTitle(titleElement:text())
                chapter:setLink(shrinkURL(linkElement:attr("href"), KEY_CHAPTER_URL))
                chapter:setOrder(i)
                chapters[#chapters + 1] = chapter
            end
        end
        
        novel:setChapters(chapters)
    end
    
    novel:setStatus(NovelStatus.PUBLISHING)
    return novel
end

local function getPassage(chapterURL)
    local url = expandURL(chapterURL, KEY_CHAPTER_URL)
    local doc = GETDocument(url)
    local contentElement = doc:selectFirst(".epcontent")
    
    if contentElement then
        return contentElement:html()
    end
    
    return ""
end

return {
    id = settings.id,
    name = settings.name,
    baseURL = settings.baseURL,
    imageURL = settings.imageURL,
    lang = settings.lang,
    isSearchIncrementing = settings.isSearchIncrementing,
    chapterType = settings.chapterType,
    listings = {
        Listing("Romans", true, listings)
    },
    search = search,
    parseNovel = parseNovel,
    getPassage = getPassage,
    shrinkURL = shrinkURL,
    expandURL = expandURL
}
