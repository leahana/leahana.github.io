(() => {
  // 初始化函数（兼容 Mermaid 11.x）
  const init = () => {
    if (typeof mermaid === "undefined") {
      // 重试
      setTimeout(init, 200);
    } else {
      // 配置 Mermaid 11.x
      mermaid.initialize({
        startOnLoad: true,
        theme: "default",
        securityLevel: "loose",
      });
      // 首次渲染
      mermaid.run?.();
    }
  };

  // 页面更新时的重载函数（PJAX 后）
  const reload = async () => {
    // Mermaid 11.x: 使用 run() 而不是 init()
    if (mermaid.run) {
      await mermaid.run();
    }
  };

  // 加载时初始化一次
  init();

  // 在 PJAX 之后重载（关键！解决刷新才能看到图的问题）
  window.addEventListener('pjax:complete', reload);
})();
