
// Create context menu when extension is installed
chrome.runtime.onInstalled.addListener(() => {
  console.log("Extension installed, creating context menu...");
  chrome.contextMenus.create({
    id: "openWithFreedium",
    title: "Open with Freedium",
    contexts: ["link", "page"]
  }, () => {
    if (chrome.runtime.lastError) {
      console.error("Context menu creation failed:", chrome.runtime.lastError);
    } else {
      console.log("Context menu created successfully");
    }
  });
});

// Handle context menu clicks
chrome.contextMenus.onClicked.addListener((info, tab) => {
  console.log("Context menu clicked:", info.menuItemId);
  if (info.menuItemId === "openWithFreedium") {
    let targetUrl;
    
    // If right-clicked on a link, use the link URL
    if (info.linkUrl) {
      targetUrl = info.linkUrl;
    } else {
      // If right-clicked on page, use the current page URL
      targetUrl = tab.url;
    }
    
    // Only proceed if the URL contains "medium.com"
    if (targetUrl && targetUrl.includes("medium.com")) {
      const encodedUrl = encodeURIComponent(targetUrl);
      const newUrl = `https://freedium.cfd/${encodedUrl}`;
      chrome.tabs.create({ url: newUrl });
    } else {
      console.log("URL does not contain medium.com, skipping forwarding");
    }
  }
});

// Keep the existing click handler for the extension icon
chrome.action.onClicked.addListener((tab) => {
  // Only proceed if the URL contains "medium.com"
  if (tab.url && tab.url.includes("medium.com")) {
    const currentUrl = encodeURIComponent(tab.url);
    const newUrl = `https://freedium.cfd/${currentUrl}`;
    chrome.tabs.create({ url: newUrl });
  } else {
    console.log("URL does not contain medium.com, skipping forwarding");
  }
});
