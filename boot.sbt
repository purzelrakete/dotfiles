resolvers ++= Seq(Resolver.url("sbt-plugin-releases",
                                          new URL("http://scalasbt.artifactoryonline.com/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns))

addSbtPlugin("org.ensime" % "ensime-sbt-cmd" % "0.0.10")
