module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        clean: ["public"],

        coffee: {
            options: {
                join: true
            },
            rocksinspace: {
                files: {
                    'coffee/rocksinspace.js': ['coffee/*.coffee']
                }
            }
        },

        uglify: {
            options: {
                mangle: {
                    except: ['Asteroid', 'AsteroidWrapper', 'Environment', 'Grid', 'Node', 'Ship']
                }
            },
            rocksinspace: {
                files: {'public/assets/rocksinspace.min.js': ['coffee/rocksinspace.js']}
            }
        },

        htmlmin: {
            options: {
                removeComments: true,
                collapseWhitespace: true
            },
            rocksinspace: {
                files: {
                    "public/index.html": "index.html"
                }
            }
        },

        copy: {
            deploy: {
                files: [
                    {flatten: true, expand: true, src: ['assets/*'], dest: 'public/assets/'}
                ]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-htmlmin');
    grunt.loadNpmTasks('grunt-contrib-copy');

    grunt.registerTask('default', "My default task.", function() {
        grunt.task.run('clean');
        grunt.log.writeln("Generating rocksinspace.min.js using Coffeescript and uglify...");
        grunt.task.run(['coffee', 'uglify']);
        grunt.log.writeln("Generating minified HTML files...");
        grunt.task.run('htmlmin');
        grunt.task.run('copy');
    });
}
