# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'arcos2'
copyright = '2024, kkk8GJ (mirkokral), emireri1498 (emir4169)'
author = 'kkk8GJ (mirkokral), emireri1498 (emir4169)'
release = '24.08a "Vertica"'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_book_theme'
html_static_path = ['_static']
extensions = [
    'sphinxcontrib.luadomain',
    'sphinx_lua'
    ]
html_show_sphinx = False
html_css_files = ["css/custom.css"]


# Available options and default values
lua_source_path = ["../src/"]
lua_source_encoding = 'utf8'
lua_source_comment_prefix = '---'
lua_source_use_emmy_lua_syntax = True
lua_source_private_prefix = '_'