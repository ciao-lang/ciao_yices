:- module(_, [], [ciaobld(bundlehooks)]).

:- doc(title,  "Bundle Hooks for Ciao-Yices").

:- use_module(library(bundle/bundle_paths), [bundle_path/3]).
:- use_module(ciaobld(third_party_install), [auto_install/2, third_party_path/2]).
:- use_module(ciaobld(builder_aux), [update_file_from_clauses/3]).

% GMP (third-party component; as in ciao_ppl)
:- def_third_party(gmp, [
    version('6.2.1'),
    source_url(tar('https://gmplib.org/download/gmp/gmp-6.2.1.tar.bz2')),
    source_md5("28971fc21cf028042d4897f02fd355ea"),
    build_system(gnu_build_system)
]).

% Yices 2 (third-party component; without MCSAT, which needs CUDD and
% LibPoly)
:- def_third_party(yices, [
    version('2.7.0'),
    source_url(tar('https://github.com/SRI-CSL/yices2/archive/refs/tags/yices-2.7.0.tar.gz', 'yices-2.7.0.tar.gz')),
    source_md5("7221a412d7602e049e11296518612b62"),
    build_system(gnu_build_system)
]).

'$builder_hook'(prepare_build_bin) :-
    auto_install(ciao_yices, gmp),
    auto_install(ciao_yices, yices),
    update_file_from_clauses([
        (:- extra_compiler_opts([~atom_concat('-I', ~third_party_path(includedir))])),
        (:- use_foreign_library_dir([~third_party_path(libdir)])),
        (:- use_foreign_library([yices]))
      ], ~bundle_path(ciao_yices, 'src/ciao_yices_config_auto.pl'), _).

'$builder_hook'(lib('src')).

% ---------------------------------------------------------------------------
% Run tests

:- use_module(ciaobld(ciaoc_aux), [runtests_dir/3]).

'$builder_hook'(test) :- !,
    % TODO: check output programmatically
    runtests_dir(ciao_yices, 'tests', [rtc_entry, dump_output]).
