// The site's entry. The shared site kit (shared/site/build.typ) turns
// every source under content/ into a page; project.typ is what it
// needs to know about MotionGfx.

#import "/shared/site/build.typ": build
#import "/project.typ": project

#build(project)
