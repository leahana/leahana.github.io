(() => {
  // 初始化函数（Mermaid 10.6.1）
  const init = () => {
    if (typeof mermaid === "undefined") {
      // 重试
      setTimeout(init, 200);
    } else {
      // 配置 Mermaid 10.x
      mermaid.initialize({
        startOnLoad: true,
        theme: "default",
        securityLevel: "loose",
      });
      // 首次渲染 - 使用 contentLoaded() 或 contentLoaded
      if (mermaid.contentLoaded) {
        mermaid.contentLoaded();
      }
    }
  };

  // 页面更新时的重载函数（PJAX 后）
  const reload = () => {
    // Mermaid 10.x: 使用 contentLoaded()
    if (mermaid.contentLoaded) {
      mermaid.contentLoaded();
    }
  };

  // 加载时初始化一次
  init();

  // 在 PJAX 之后重载（关键！解决刷新才能看到图的问题）
  window.addEventListener('pjax:complete', reload);
})();
