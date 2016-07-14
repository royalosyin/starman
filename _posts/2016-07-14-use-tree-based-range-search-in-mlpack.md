---
layout: post
title: 使用MLPACK库中的邻居搜索算法
author: 董理
lang: zh
permalink: /2016-07-14/use-tree-based-range-search-in-mlpack/
---

[MLPACK](http://www.mlpack.org)是一个使用C++编写的机器学习算法库，提供了多种算法，其中邻居搜索是我比较关心的。由于采用C++模板设计程序实现，MLPACK中的同一类算法都采用相同的接口，大大方便不同算法的切换。下面是我对其中基于树形数据结构的邻居搜索算法的示例：

```c++
#include <mlpack/core.hpp>
#include <mlpack/core/tree/rectangle_tree.hpp>
#include <mlpack/core/tree/cover_tree.hpp>
#include <mlpack/methods/range_search/range_search.hpp>

int main(int argc, char *argv[]) {
  mlpack::CLI::ParseCommandLine(argc, argv);

  const size_t N = atoi(argv[1]);

  // Test dataset.
  arma::mat dataset(3, N, arma::fill::randu);

  mlpack::math::Range r(0, 0.1);

  // - KDTree
  std::cout << "[Notice]: Running KDTree." << std::endl;
  mlpack::Timer::Start("KDTree-1");
  mlpack::range::RangeSearch<mlpack::metric::EuclideanDistance, arma::mat, mlpack::tree::KDTree> a(dataset);
  mlpack::Timer::Stop("KDTree-1");
  std::vector<std::vector<size_t>> neighbors_a;
  std::vector<std::vector<double>> distances_a;
  mlpack::Timer::Start("KDTree-2");
  a.Search(r, neighbors_a, distances_a);
  mlpack::Timer::Stop("KDTree-2");

  // - CoverTree
  std::cout << "[Notice]: Running CoverTree." << std::endl;
  mlpack::Timer::Start("CoverTree-1");
  mlpack::range::RangeSearch<mlpack::metric::EuclideanDistance, arma::mat, mlpack::tree::StandardCoverTree> b(dataset);
  mlpack::Timer::Stop("CoverTree-1");
  std::vector<std::vector<size_t>> neighbors_b;
  std::vector<std::vector<double>> distances_b;
  mlpack::Timer::Start("CoverTree-2");
  b.Search(r, neighbors_b, distances_b);
  mlpack::Timer::Stop("CoverTree-2");

  // - BallTree
  std::cout << "[Notice]: Running BallTree." << std::endl;
  mlpack::Timer::Start("BallTree-1");
  mlpack::range::RangeSearch<mlpack::metric::EuclideanDistance, arma::mat, mlpack::tree::BallTree> c(dataset);
  mlpack::Timer::Stop("BallTree-1");
  std::vector<std::vector<size_t>> neighbors_c;
  std::vector<std::vector<double>> distances_c;
  mlpack::Timer::Start("BallTree-2");
  c.Search(r, neighbors_c, distances_c);
  mlpack::Timer::Stop("BallTree-2");

  // - RTree
  std::cout << "[Notice]: Running RTree." << std::endl;
  mlpack::Timer::Start("RTree-1");
  mlpack::range::RangeSearch<mlpack::metric::EuclideanDistance, arma::mat, mlpack::tree::RTree> d(dataset);
  mlpack::Timer::Stop("RTree-1");
  std::vector<std::vector<size_t>> neighbors_d;
  std::vector<std::vector<double>> distances_d;
  mlpack::Timer::Start("RTree-2");
  d.Search(r, neighbors_d, distances_d);
  mlpack::Timer::Stop("RTree-2");

  // - RStarTree
  std::cout << "[Notice]: Running RStarTree." << std::endl;
  mlpack::Timer::Start("RStarTree-1");
  mlpack::range::RangeSearch<mlpack::metric::EuclideanDistance, arma::mat, mlpack::tree::RStarTree> e(dataset);
  mlpack::Timer::Stop("RStarTree-1");
  std::vector<std::vector<size_t>> neighbors_e;
  std::vector<std::vector<double>> distances_e;
  mlpack::Timer::Start("RStarTree-2");
  e.Search(r, neighbors_e, distances_e);
  mlpack::Timer::Stop("RStarTree-2");

  // - XTree
  std::cout << "[Notice]: Running XTree." << std::endl;
  mlpack::Timer::Start("XTree-1");
  mlpack::range::RangeSearch<mlpack::metric::EuclideanDistance, arma::mat, mlpack::tree::XTree> f(dataset);
  mlpack::Timer::Stop("XTree-1");
  std::vector<std::vector<size_t>> neighbors_f;
  std::vector<std::vector<double>> distances_f;
  mlpack::Timer::Start("XTree-2");
  f.Search(r, neighbors_f, distances_f);
  mlpack::Timer::Stop("XTree-2");

  return 0;
}
```

可以看到各段对不同树类（`KDTree`、 `CoverTree`、 `BallTree`、 `RTree`、 `RStarTree`、 `XTree`）调用的程序基本一致，除了关于树类的模板参数，因此可以快速试验哪种算法最合适。
