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

local function getSearch(data)
    local page = data[PAGE_INDEX] or 1
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
            novel:setLink(linkElement:attr("href"))
            
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

local function parseNovel(url)
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
    
    novel:setStatus(NovelStatus.PUBLISHING)
    return novel
end

local function getChapters(url)
    local doc = GETDocument(url)
    local chapters = {}
    
    local chapterElements = doc:select(".eplister ul li")
    
    for i = 0, chapterElements:size() - 1 do
        local element = chapterElements:get(i)
        local linkElement = element:selectFirst("a")
        local titleElement = element:selectFirst(".chapternum")
        
        if linkElement and titleElement then
            local chapter = NovelChapter()
            chapter:setTitle(titleElement:text())
            chapter:setLink(linkElement:attr("href"))
            chapter:setOrder(i)
            chapters[#chapters + 1] = chapter
        end
    end
    
    return chapters
end

local function getPassageData(chapterURL)
    local doc = GETDocument(chapterURL)
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
    getSearch = getSearch,
    parseNovel = parseNovel,
    getChapters = getChapters,
    getPassageData = getPassageData
}
