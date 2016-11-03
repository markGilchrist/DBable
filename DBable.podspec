#
# Be sure to run `pod lib lint DBable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DBable'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DBable.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'The idea for this pod is to remove the legwork from passing objects and storeing them to an Sqlite db.
    My intention with this library is to create strings that are a good guess for most of the leg work you are going to do. It is NOT nor
    will it ever be a solutuion to all your problems you will have to write some custom strings from time to time.'

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/DBable'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'markgameforeverything' => 'theheadchef@gameforeverything.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/DBable.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DBable/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DBable' => ['DBable/Assets/*.png']
  # }


end
