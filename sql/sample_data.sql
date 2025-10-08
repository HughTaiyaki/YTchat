-- YouTube Chat 示例数据
-- 插入测试和演示用的示例数据

USE `ytchat`;

-- 清空现有数据（可选）
-- DELETE FROM chat_messages;
-- DELETE FROM video_segments;
-- DELETE FROM videos;

-- 插入示例视频数据
INSERT INTO `videos` (`youtube_id`, `title`, `description`, `thumbnail`, `duration`) VALUES
('Ylvr5hl6hYo', 'Go语言从入门到精通 - 完整教程', '这是一个全面的Go语言学习教程，从基础语法到高级特性，包含大量实战项目和代码示例。适合初学者和有经验的开发者。', 'https://img.youtube.com/vi/Ylvr5hl6hYo/maxresdefault.jpg', 7200),
('dQw4w9WgXcQ', 'Python数据分析实战项目', '使用Python进行数据分析的完整项目教程，包括数据清洗、可视化、机器学习等核心技能。', 'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg', 5400),
('jNQXAC9IVRw', 'React前端开发完整指南', '从零开始学习React框架，包括组件开发、状态管理、路由配置等现代前端开发技能。', 'https://img.youtube.com/vi/jNQXAC9IVRw/maxresdefault.jpg', 6300),
('M7lc1UVf-VE', 'Docker容器化部署实践', '学习Docker的基本概念和实际应用，包括镜像构建、容器编排、生产环境部署等。', 'https://img.youtube.com/vi/M7lc1UVf-VE/maxresdefault.jpg', 4800);

-- 插入Go语言教程的片段
INSERT INTO `video_segments` (`video_id`, `start_time`, `end_time`, `content`, `summary`) VALUES
(1, 0, 600, 'Go语言基础语法介绍', '介绍Go语言的基本语法、变量声明、数据类型、控制结构等基础概念。'),
(1, 600, 1200, '函数和方法详解', '深入讲解Go语言的函数定义、参数传递、返回值、方法绑定等核心概念。'),
(1, 1200, 1800, '结构体和接口', '学习Go语言的面向对象编程，包括结构体定义、方法实现、接口设计等。'),
(1, 1800, 2400, '并发编程基础', '介绍Go语言的goroutine和channel，学习并发编程的基本模式。'),
(1, 2400, 3000, '错误处理机制', '学习Go语言的错误处理方式，包括error接口、panic和recover等。'),
(1, 3000, 3600, '包管理和模块系统', '了解Go modules的使用，学习如何管理项目依赖和版本控制。'),
(1, 3600, 4200, 'Web开发实战', '使用Gin框架开发RESTful API，学习Web开发的最佳实践。'),
(1, 4200, 4800, '数据库操作', '学习Go语言与数据库的交互，包括SQL操作和ORM使用。'),
(1, 4800, 5400, '测试和调试', '掌握Go语言的测试框架，学习单元测试和性能测试的方法。'),
(1, 5400, 6000, '项目实战案例', '通过完整的项目案例，综合运用所学知识。'),
(1, 6000, 6600, '性能优化技巧', '学习Go程序的性能优化方法，包括内存管理和并发优化。'),
(1, 6600, 7200, '部署和运维', '学习Go应用的部署策略和运维监控。');

-- 插入Python数据分析的片段
INSERT INTO `video_segments` (`video_id`, `start_time`, `end_time`, `content`, `summary`) VALUES
(2, 0, 600, 'Python数据分析环境搭建', '安装和配置Python数据分析所需的库，包括pandas、numpy、matplotlib等。'),
(2, 600, 1200, '数据加载和清洗', '学习如何从各种数据源加载数据，并进行数据清洗和预处理。'),
(2, 1200, 1800, '数据探索和可视化', '使用matplotlib和seaborn进行数据可视化，发现数据中的模式和趋势。'),
(2, 1800, 2400, '统计分析基础', '学习描述性统计、假设检验等统计分析方法。'),
(2, 2400, 3000, '机器学习入门', '介绍机器学习的基本概念，使用scikit-learn进行模型训练。'),
(2, 3000, 3600, '时间序列分析', '学习时间序列数据的处理和分析方法。'),
(2, 3600, 4200, '文本数据分析', '使用NLTK和spaCy进行文本数据的处理和分析。'),
(2, 4200, 4800, '大数据处理', '学习使用Dask和Spark处理大规模数据集。'),
(2, 4800, 5400, '项目实战案例', '通过真实的数据分析项目，综合运用所学技能。');

-- 插入React教程的片段
INSERT INTO `video_segments` (`video_id`, `start_time`, `end_time`, `content`, `summary`) VALUES
(3, 0, 600, 'React基础概念', '介绍React的核心概念，包括组件、JSX、虚拟DOM等。'),
(3, 600, 1200, '组件开发实践', '学习如何创建和组合React组件，理解组件的生命周期。'),
(3, 1200, 1800, '状态管理', '学习useState和useEffect Hook，掌握组件状态管理。'),
(3, 1800, 2400, 'Props和事件处理', '学习组件间通信和事件处理机制。'),
(3, 2400, 3000, '路由配置', '使用React Router实现单页应用的路由功能。'),
(3, 3000, 3600, '状态管理进阶', '学习Redux和Context API进行全局状态管理。'),
(3, 3600, 4200, '性能优化', '学习React应用的性能优化技巧，包括memo、useMemo等。'),
(3, 4200, 4800, '测试策略', '学习React组件的测试方法，包括单元测试和集成测试。'),
(3, 4800, 5400, '构建和部署', '学习React应用的构建优化和部署策略。'),
(3, 5400, 6300, '项目实战', '通过完整的项目案例，综合运用React开发技能。');

-- 插入Docker教程的片段
INSERT INTO `video_segments` (`video_id`, `start_time`, `end_time`, `content`, `summary`) VALUES
(4, 0, 600, 'Docker基础概念', '介绍Docker的基本概念，包括镜像、容器、仓库等核心概念。'),
(4, 600, 1200, 'Dockerfile编写', '学习如何编写Dockerfile，构建自定义镜像。'),
(4, 1200, 1800, '容器操作管理', '学习Docker容器的创建、启动、停止、删除等基本操作。'),
(4, 1800, 2400, '数据卷管理', '学习Docker数据卷的使用，实现数据持久化。'),
(4, 2400, 3000, '网络配置', '学习Docker网络配置，实现容器间通信。'),
(4, 3000, 3600, 'Docker Compose', '学习使用Docker Compose进行多容器应用编排。'),
(4, 3600, 4200, '生产环境部署', '学习Docker在生产环境中的部署和运维策略。'),
(4, 4200, 4800, '监控和日志', '学习Docker应用的监控和日志管理方法。');

-- 插入示例聊天记录
INSERT INTO `chat_messages` (`question`, `answer`, `video_id`, `start_time`, `end_time`) VALUES
('Go语言有什么特点？', 'Go语言具有简洁的语法、强大的并发支持、快速的编译速度和优秀的性能。它特别适合构建高并发的网络服务和微服务架构。', 1, 0, 600),
('如何学习Go语言？', '建议从基础语法开始，然后学习函数、结构体、接口等核心概念，接着学习并发编程，最后通过实际项目来巩固知识。', 1, 600, 1200),
('Python数据分析需要哪些库？', 'Python数据分析主要需要pandas用于数据处理、numpy用于数值计算、matplotlib和seaborn用于数据可视化、scikit-learn用于机器学习。', 2, 0, 600),
('React和Vue有什么区别？', 'React使用JSX语法，采用单向数据流，学习曲线较陡峭但生态丰富；Vue使用模板语法，双向数据绑定，学习曲线平缓，更适合初学者。', 3, 0, 600),
('Docker有什么优势？', 'Docker提供了容器化技术，可以实现应用的环境一致性、快速部署、资源隔离、易于扩展等优势，是现代DevOps的重要工具。', 4, 0, 600),
('Go语言的并发模型是什么？', 'Go语言使用goroutine实现轻量级并发，通过channel进行协程间通信，采用CSP（Communicating Sequential Processes）模型。', 1, 2400, 3000),
('如何优化React应用性能？', '可以通过使用React.memo、useMemo、useCallback等Hook，避免不必要的重渲染，使用代码分割和懒加载等技术来优化性能。', 3, 3600, 4200),
('Docker容器如何持久化数据？', 'Docker容器可以通过数据卷（Volume）和绑定挂载（Bind Mount）来实现数据持久化，确保容器重启后数据不丢失。', 4, 1800, 2400);

-- 显示插入结果
SELECT 'Sample data inserted successfully!' as message;
SELECT 
    (SELECT COUNT(*) FROM videos) as video_count,
    (SELECT COUNT(*) FROM video_segments) as segment_count,
    (SELECT COUNT(*) FROM chat_messages) as message_count;
