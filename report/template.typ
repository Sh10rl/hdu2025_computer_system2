#let project(
  title: "课程设计报告",
  course_name: "",     
  school: "计算机学院", 
  major: "",           
  class_name: "",      
  student_id: "",      
  student_name: "",    
  contribution: "",
  teacher: "",         
  date: datetime.today().display("[year]年[month]月[day]日"),
  logo: none,          
  body
) = {
  // 1. 全局页面设置
  set document(author: student_name, title: title)
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    numbering: "1",
  )
  
  // 2. 正文字体设置
  set text(
    font: ("Times New Roman", "SimSun", "Songti SC", "STSong", "Noto Serif CJK SC"),
    size: 12pt,
    lang: "zh",
    region: "cn"
  )

  // 3. 标题样式
  set heading(numbering: "1.1")
  
  show heading: it => {
    set par(first-line-indent: 0em)
    
    set text(
      font: ("Times New Roman", "Source Han Serif SC", "Noto Serif CJK SC", "SimSun", "Songti SC", "STSong"),
      weight: "bold"
    )
    
    block(above: 1.5em, below: 1em)[
      #if it.level == 1 {
        text(size: 16pt)[
          #if it.numbering != none { counter(heading).display() }
          #it.body
        ]
      } else {
        text(size: 14pt)[
          #if it.numbering != none { counter(heading).display() }
          #it.body
        ]
      }
    ]
  }

  // 4. 代码块样式
  show raw.where(block: true): block.with(
    fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )
  show raw: set text(font: ("Courier New", "Consolas", "Monaco", "Roboto Mono"))

  // 5. 图表样式
  show figure: it => {
    set par(first-line-indent: 0em)
    it
  }
  show image: it => {
    set par(first-line-indent: 0em)
    it
  }

  // 6. 封面设计
  {
    set page(numbering: none)
    set par(first-line-indent: 0em)
    
    align(center)[
      #if logo != none {
        // 有 logo 时，显示大图
        v(1cm)
        image(logo, width: 60%) 
        v(1cm)
      } else {
        // 没有 logo 时的回退显示
        v(4cm)
        text(size: 24pt, font: ("Source Han Serif SC", "SimSun", "Songti SC", "Noto Serif CJK SC"), weight: "bold")[杭州电子科技大学]
      }
      
      #let title_gap = 2.5cm
      #v(title_gap)
      #text(size: 32pt, font: ("Source Han Serif SC", "SimSun", "Songti SC", "Noto Serif CJK SC"), weight: "bold")[课程设计报告]
      #v(title_gap)
      
      #block(width: 320pt)[
        #set text(size: 15pt)
        #let info_key(body) = align(right)[#strong(body)]
        #let info_value(body) = align(center)[#rect(width: 100%, stroke: (bottom: 1pt))[#body]]
        
        #grid(
          columns: (85pt, 1fr),
          row-gutter: 18pt,
          info_key("课程名称："), info_value(course_name),
          info_key("学院："), info_value(school),
          info_key("专业班级："), info_value(major + " " + class_name),
          info_key("学生姓名："), info_value(student_name),
          info_key("学号："), info_value(student_id),
          // 新增成员贡献栏
          info_key("成员贡献："), info_value(contribution),
          info_key("指导教师："), info_value(teacher),
          info_key("日期："), info_value(date),
        )
      ]
    ]
    pagebreak()
  }

  // 7. 目录
  {
    set page(numbering: "I")
    set par(first-line-indent: 0em)
    
    show outline.entry: it => {
      text(font: ("Times New Roman", "Source Han Serif SC", "SimSun", "Songti SC", "Noto Serif CJK SC"))[#it]
    }
    
    outline(title: "目 录", indent: 2em, depth: 3)
    pagebreak()
  }

  // 8. 正文环境
  set page(numbering: "1")
  counter(page).update(1)
  set par(first-line-indent: 2em, justify: true, leading: 1.0em)

  body
}
